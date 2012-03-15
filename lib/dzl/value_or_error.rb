class Dzl::ValueOrError
  attr_reader :error, :value

  def initialize(opts = {})
    @error = opts[:error] || opts[:e]
    @value = opts[:value] || opts[:v]

    if @error && @value
      raise ArgumentError, "it's ValueOrError, not ValueAndError"
    end

    unless @error || opts.has_key?(:v) || opts.has_key?(:value)
      raise ArgumentError, "Must provide :value key, even if nil"
    end
  end

  def error?
    @error.present?
  end

  def value?
    !error?
  end

  def to_s
    if error?
      "e: #{@error.inspect}"
    else
      "v: #{@value.inspect}"
    end
  end
end
