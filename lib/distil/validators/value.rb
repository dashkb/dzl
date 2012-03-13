module Distil::Validators
  class Value < Distil::Validator
    def initialize
      @conditions = []
    end

    def validate(input)
      valid = @conditions.all? do |op, n|
        return Distil::ValueOrError.new(
          e: :value_validation_failed
        ) unless input.respond_to?(op)
        
        input.send(op, n)
      end

      if valid
        Distil::ValueOrError.new(v: input)
      else
        Distil::ValueOrError.new(e: :value_validation_failed)
      end
    end

    [:==, :<=, :>=, :<, :>].each do |op|
      define_method(op) do |n|
        @conditions << [op, n]
      end
    end
  end
end