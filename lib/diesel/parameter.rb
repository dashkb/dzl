class Diesel::DSL::Parameter
  attr_reader :name

  def initialize(name, opts)
    @name = name
    @opts = opts
    @validations = {
      matches: [],
      allowed_values: [],
      type: nil
    }
  end

  def matches(regex)
    @validations[:matches] << regex
  end

  def allowed_values(ary)
    @validations[:allowed_values] = ary
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
end