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

  def overwrite_opts(opts)
    @opts = opts
  end

  def type_valid?(input)
    if @validations[:type] == Numeric
      input.to_i.to_s == input
    elsif @validations[:type] == String
      true
    end
  end

  def validation_error(input)
    # Validate type
    return nil if !@opts[:required] && input.nil?
    return :missing_required_param if @opts[:required] && input.nil?
    return :type_mismatch unless type_valid?(input)

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

    nil
  end

  def as_json(opts=nil)
    {
      opts: @opts,
      validations: @validations
    }
  end
end