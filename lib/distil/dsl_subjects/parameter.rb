require 'distil/dsl_proxies/parameter'

class Distil::ParameterError < StandardError; end

class Distil::DSLSubjects::Parameter < Distil::DSLSubject
  require 'distil/dsl_subjects/parameter/type_conversion'
  require 'distil/dsl_subjects/parameter/allowed_values'
  include TypeConversion
  include AllowedValues

  attr_reader :validations, :opts
  attr_writer :default

  def initialize(name, opts)
    @name = name
    @opts = opts
    @validations = {
      type: String
    }
    @dsl_proxy = Distil::DSLProxies::Parameter.new(self)
  end

  def clone
    deep_copy = self.dup
    deep_copy.dup_data
    deep_copy
  end

  def dup_data
    @opts = @opts.clone
    @validations = @validations.clone
    @dsl_proxy = Distil::DSLProxies::Parameter.new(self)
  end

  def param_type
    @validations[:type]
  end

  def overwrite_opts(opts)
    if @opts[:in_path] && opts[:required] == false
      raise Distil::ParameterError.new("Cannot set in-path param #{name} to optional")
    end

    @opts.merge!(opts)
  end

  # Returns a symbol describe the error if error,
  # returns the transformed value if not
  # TODO symbol values?
  def validate(input)
    # Validate type
    unless input
      if @opts[:required]
        return Distil::ValueOrError.new(
          e: @opts[:header] ? :missing_required_header : :missing_required_param
        )
      else
        return Distil::ValueOrError.new(
          v: @opts.has_key?(:default_value) ? @opts[:default_value] : :__no_value__
        )
      end
    end

    input = convert_type(input)
    return input if input.error?

    input = prevalidate_transform(input.value)
    return input if input.error?

    input = allowed_values(input.value)
    return input if input.error?

    input = regex_match(input.value)
    return input if input.error?

    # Validator procs
    if @validations.has_key?(:procs)
      @validations[:procs].each do |vproc|
        vproc.call(input.value) or
          return Distil::ValueOrError.new(e: :validator_poc_failed)
      end
    end

    # Validator classes
    @validations.select {|k, v| v.kind_of?(Distil::Validator)}.each do |vary|
      name, validator = vary
      input = validator.validate(input.value)
      return input if input.error?
    end

    Distil::ValueOrError.new(v: input.value)
  end

  def as_json(opts=nil)
    {
      opts: @opts,
      validations: @validations
    }
  end
end