module Dzl::Validators
  class Value < Dzl::Validator
    attr_reader :conditions
    def initialize
      @conditions = []
    end

    def validate(input)
      valid = @conditions.all? do |op, n|
        return Dzl::ValueOrError.new(
          e: :value_validation_failed
        ) unless input.respond_to?(op)
        
        input.send(op, n)
      end

      if valid
        Dzl::ValueOrError.new(v: input)
      else
        Dzl::ValueOrError.new(e: :value_validation_failed)
      end
    end

    [:==, :<=, :>=, :<, :>].each do |op|
      define_method(op) do |n|
        @conditions << [op, n]
      end
    end
  end
end