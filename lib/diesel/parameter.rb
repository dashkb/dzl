class Diesel::DSL::Parameter
  attr_reader :name, :opts

  def initialize(name, opts)
    @name = name
    @opts = opts
    @validations = {
      type: String
    }
  end

  def matches(regex)
    @validations[:matches] ||= []
    @validations[:matches] << regex
  end

  def allowed_values(ary)
    @validations[:allowed_values] ||= []
    (@validations[:allowed_values] += ary).uniq!
  end

  def type(type)
    @validations[:type] = type
  end

  def integer
    matches(/\d+/)
  end

  def overwrite_opts(opts)
    @opts = opts
  end

  def valid?(input)
    return false unless input.is_a?(@validations[:type])

    if input.is_a?(String) && @validations.has_key?(:matches)
      return false unless @validations[:matches].any? do |might_match|
        might_match.match(input) != nil
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