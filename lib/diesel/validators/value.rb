module Diesel::Validators
  class Value < Diesel::Validator
    def initialize
      @conditions = []
    end

    def validate(input)
      valid = @conditions.all? do |op, n|
        return Diesel::ValueOrError.new(
          e: :value_validation_failed
        ) unless input.respond_to?(op)
        
        input.send(op, n)
      end

      if valid
        Diesel::ValueOrError.new(v: input)
      else
        Diesel::ValueOrError.new(e: :value_validation_failed)
      end
    end

    [:==, :<=, :>=, :<, :>].each do |op|
      define_method(op) do |n|
        @conditions << [op, n]
      end
    end
  end
end