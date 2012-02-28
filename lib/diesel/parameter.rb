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

  def valid?(input)
    # Validate type
    return false unless input.is_a?(@validations[:type])

    # Validate regex matches
    if input.is_a?(String) && @validations.has_key?(:matches)
      return false unless @validations[:matches].any? do |might_match|
        might_match.match(input) != nil
      end
    end

    # Validate by procs see?
    if @validations.has_key?(:procs)
      return false if @validations[:procs].one? do |proc|
        !proc.call(input)
      end
    end

    true
  end

  def as_json(opts=nil)
    {
      opts: @opts,
      validations: @validations
    }
  end
end