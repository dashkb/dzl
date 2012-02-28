require 'diesel/validators/size'

module Diesel::ParameterDSL
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

  def validate_with
    raise ArgumentError unless block_given?
    @validations[:procs] ||= []
    @validations[:procs] << Proc.new
  end

  # TODO implement these
  def downcase

  end

  def to_sym

  end

  # The idea behind this method is to let one
  # parameter validate against the value of another
  # obviously there's the circular validation problem
  # but perhaps we can catch a circular reference
  # when it's defined and raise DontDoThat
  def params
    raise Diesel::NYI
  end
end