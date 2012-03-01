module Diesel::ParameterDSL
  class ValueOrError
    attr_reader :error, :value

    def initialize(error, value=nil)
      @error = error
      @value = value
    end

    def valid?
      @error.nil? ? true : false
    end

  end
end
