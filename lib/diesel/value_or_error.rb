class Diesel::ValueOrError
  attr_reader :error, :value

  def initialize(opts = {})
    @error = opts[:error] || opts[:e]
    @value = opts[:value] || opts[:v]

    if @error && @value
      raise ArgumentError, "it's ValueOrError, not ValueAndError"
    end
  end

  def valid?
    @error.nil? ? true : false
  end

  def error?
    @error.present?
  end

  def value?
    @value.present?
  end
end
