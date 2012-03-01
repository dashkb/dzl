require 'diesel/parameter_dsl'

class Diesel::Parameter
  include Diesel::ParameterDSL
  attr_reader :name, :opts

  def initialize(name, opts)
    @name = name
    @opts = opts
    @validations = {
      type: String
    }
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
    return nil if !@opts[:required] && input.nil?
    return :missing_required_param if @opts[:required] && input.nil?

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
      end
    rescue StandardError => e
      return :type_conversion_error
    end

    return :type_mismatch unless input.is_a?(param_type)

    # Validate regex matches
    if input.is_a?(String) && @validations.has_key?(:matches)
      return :regex_no_match unless @validations[:matches].any? do |might_match|
        might_match.match(input) != nil
      end
    end

    # Validate by procs see?
    if @validations.has_key?(:procs)
      return :proc_validate_failed if @validations[:procs].one? do |proc|
        !proc.call(input)
      end
    end

    # Validator classes
    @validations.select {|k, v| v.kind_of?(Diesel::Validator)}.each do |vary|
      name, validator = vary
      return :validator_object_failed unless validator.validate(input)
    end

    input
  end

  def as_json(opts=nil)
    {
      opts: @opts,
      validations: @validations
    }
  end
end