require 'diesel/validators/size'

class Diesel::DSLProxies::Parameter < Diesel::DSLProxy
  alias_method :orig_mm, :method_missing
  attr_reader :default_value
  def method_missing(m, *args, &block)
    validator = "Diesel::Validators::#{m.to_s.camelize}".constantize rescue nil
    if !validator
      orig_mm(m, *args, &block)
    else
      @subject.validations[m] ||= validator.new
    end
  end

  alias_method :orig_respond_to?, :respond_to?
  def respond_to?(m, *args, &block)
    orig_respond_to?(m, *args, &block) ||
    ("Diesel::Validators::#{m.to_s.camelize}".constantize rescue nil)
  end

  # Currently we allow the parameter to match ANY of these,
  # perhaps we should require it to match them ALL
  # or make it configurable
  # TODO
  def matches(regex)
    @subject.validations[:matches] ||= []
    @subject.validations[:matches] << regex
  end

  def allowed_values(ary)
    @subject.validations[:allowed_values] ||= []
    ary = ary.to_a if ary.is_a?(Range) # TODO or whatever
    (@subject.validations[:allowed_values] += ary).uniq!
  end

  def disallowed_values(ary)
    @subject.validations[:disallowed_values] ||= []
    ary = ary.to_a if ary.is_a?(Range) # TODO or whatever
    (@subject.validations[:disallowed_values] += ary).uniq!
  end

  def type(type, type_opts = {})
    @subject.validations[:type] = type
    @subject.opts[:type_opts] = type_opts
  end

  def integer
    matches(/\d+/)
  end

  def default(val)
    @subject.default = val
  end

  def validate_with
    raise ArgumentError unless block_given?
    @subject.validations[:procs] ||= []
    @subject.validations[:procs] << Proc.new
  end

  def prevalidate_transform(&block)
    @subject.validations[:prevalidate_transform] ||= []
    @subject.validations[:prevalidate_transform] << block
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