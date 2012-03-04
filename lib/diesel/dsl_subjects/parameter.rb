require 'diesel/dsl_proxies/parameter'

class Diesel::ParameterError < StandardError; end

class Diesel::DSLSubjects::Parameter < Diesel::DSLSubject
  require 'diesel/dsl_subjects/parameter/type_conversion'
  require 'diesel/dsl_subjects/parameter/allowed_values'
  include TypeConversion
  include AllowedValues

  attr_reader :validations
  attr_writer :default

  def initialize(name, opts)
    @name = name
    @opts = opts
    @validations = {
      type: String
    }
    @dsl_proxy = Diesel::DSLProxies::Parameter.new(self)
    @default = nil
  end

  def param_type
    @validations[:type]
  end

  def overwrite_opts(opts)
    if @opts[:in_path] && opts[:required] == false
      raise Diesel::ParameterError.new("Cannot set in-path param #{name} to optional")
    end

    @opts = opts
  end

  # Returns a symbol describe the error if error,
  # returns the transformed value if not
  # TODO symbol values?
  def validate(input)
    # Validate type
    unless input
      if @opts[:required]
        return Diesel::ValueOrError.new(e: :missing_required_param)
      else
        return Diesel::ValueOrError.new(v: @default)
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

    # Validator classes
    @validations.select {|k, v| v.kind_of?(Diesel::Validator)}.each do |vary|
      name, validator = vary
      input = validator.validate(input.value)
      return input if input.error?
    end

    Diesel::ValueOrError.new(v: input.value)
  end

  def as_json(opts=nil)
    {
      opts: @opts,
      validations: @validations
    }
  end
end