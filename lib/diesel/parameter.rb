require 'diesel/validators/size'

class Diesel::DSL::Parameter
  attr_reader :name, :opts

  def initialize(name, opts)
    @name = name
    @opts = opts
    @validations = {
      type: String
    }
  end

  # Currently we allow the parameter to match ANY of these,
  # perhaps we should require it to match them ALL
  # or make it configurable
  # TODO
  def matches(regex)
    @validations[:matches] ||= []
    @validations[:matches] << regex
  end

  def allowed_values(ary)
    @validations[:allowed_values] ||= []
    ary = ary.to_a if ary.is_a?(Range) # TODO or whatever
    (@validations[:allowed_values] += ary).uniq!
  end

  def size
    @validations[:size] ||= Diesel::Validators::Size.new
  end

  def type(type)
    @validations[:type] = type
  end

  def integer
    matches(/\d+/)
  end

  def default(val)
    @default = val
  end

  # TODO implement these
  def downcase

  end

  def to_sym

  end

  def overwrite_opts(opts)
    @opts = opts
  end

  def params
    raise Diesel::NYI
  end

  def validate_with
    raise ArgumentError unless block_given?
    @validations[:procs] ||= []
    @validations[:procs] << Proc.new
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