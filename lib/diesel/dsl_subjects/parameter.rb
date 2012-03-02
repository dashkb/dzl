require 'diesel/dsl_proxies/parameter'

class Diesel::DSLSubjects::Parameter < Diesel::DSLSubject
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
    @opts = opts
  end

  # Returns a symbol describe the error if error,
  # returns the transformed value if not
  # TODO symbol values?
  def validation_error(input)
    # Validate type
    return Diesel::ValueOrError.new(v: @default) if !@opts[:required] && input.nil?
    return Diesel::ValueOrError.new(e: :missing_required_param) if @opts[:required] && input.nil?

    # Try to convert to expected type
    begin
      if param_type == String
        input = input.to_s
      elsif param_type == Array
        input = input.split(' ')
      elsif param_type == Numeric
        numerified = input.to_i.to_s
        raise unless numerified == input
        input = input.to_i
      elsif param_type == Date || param_type == Time
        input = Time.parse(input)
        input = input.to_date if param_type == Date
      end
    rescue StandardError => e
      return Diesel::ValueOrError.new(e: :type_conversion_error)
    end

    return Diesel::ValueOrError.new(e: :type_mismatch) unless input.is_a?(param_type)

    # Transform as requested by the user if need be
    if @validations.has_key?(:prevalidate_transform)
      @validations[:prevalidate_transform].each do |transform|
        input = transform.call(input)
      end
    end

    # Validate allowed values
    if param_type == Array && @validations.has_key?(:allowed_values)
      valid = input.all? { |value| @validations[:allowed_values].include?(value) }
      return Diesel::ValueOrError.new(e: :allowed_values_failed) unless valid
    end

    # Validate regex matches
    if input.is_a?(String) && @validations.has_key?(:matches)
      return Diesel::ValueOrError.new(e: :regex_no_match) unless @validations[:matches].any? do |might_match|
        might_match.match(input) != nil
      end
    end

    # Validate by procs see?
    if @validations.has_key?(:procs)
      return Diesel::ValueOrError.new(e: :proc_validate_failed) if @validations[:procs].one? do |proc|
        !proc.call(input)
      end
    end

    # Validator classes
    @validations.select {|k, v| v.kind_of?(Diesel::Validator)}.each do |vary|
      name, validator = vary
      return Diesel::ValueOrError.new(e: :validator_object_failed) unless validator.validate(input)
    end

    Diesel::ValueOrError.new(v: input)
  end

  def as_json(opts=nil)
    {
      opts: @opts,
      validations: @validations
    }
  end
end