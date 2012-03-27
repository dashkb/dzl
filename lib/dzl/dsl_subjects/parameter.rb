require 'dzl/dsl_proxies/parameter'

class Dzl::ParameterError < StandardError; end

class Dzl::DSLSubjects::Parameter < Dzl::DSLSubject
  require 'dzl/dsl_subjects/parameter/type_conversion'
  require 'dzl/dsl_subjects/parameter/allowed_values'
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
    @dsl_proxy = Dzl::DSLProxies::Parameter.new(self)
  end

  def clone
    deep_copy = self.dup
    deep_copy.dup_data
    deep_copy
  end

  def dup_data
    @opts = @opts.clone
    @validations = @validations.clone
    @dsl_proxy = Dzl::DSLProxies::Parameter.new(self)
  end

  def param_type
    @validations[:type]
  end

  def overwrite_opts(opts)
    if @opts[:in_path] && opts[:required] == false
      raise Dzl::ParameterError.new("Cannot set in-path param #{name} to optional")
    end

    @opts.merge!(opts)
  end

  # Returns a symbol describe the error if error,
  # returns the transformed value if not
  # TODO symbol values?
  def validate(input, opts = {})
    # Validate type
    unless input
      if @opts[:required]
        return Dzl::ValueOrError.new(
          e: @opts[:header] ? :missing_required_header : :missing_required_param
        )
      else
        return Dzl::ValueOrError.new(
          v: @opts.has_key?(:default_value) ? @opts[:default_value] : :__no_value__
        )
      end
    end

    input = begin
      if opts[:preformatted]
        if input.is_a?(param_type)
          if param_type == Hash
            if @opts[:type_opts][:validator].valid?(input)
              Dzl::ValueOrError.new(
                v: input
              )
            else
              Dzl::ValueOrError.new(
                e: :hash_validation_failed
              )
            end
          else
            Dzl::ValueOrError.new(
              v: input
            )
          end
        else
          Dzl::ValueOrError.new(
            e: :type_conversion_error
          )
        end
      else
        convert_type(input)
      end
    end
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
          return Dzl::ValueOrError.new(e: :validator_poc_failed)
      end
    end

    # Validator classes
    @validations.select {|k, v| v.kind_of?(Dzl::Validator)}.each do |vary|
      name, validator = vary
      input = validator.validate(input.value)
      return input if input.error?
    end

    Dzl::ValueOrError.new(v: input.value)
  end

  def as_json(opts=nil)
    {
      opts: @opts,
      validations: @validations
    }
  end
end