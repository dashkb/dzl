module Dzl::Validators
  class Size < Dzl::Validator
    attr_reader :conditions
    def initialize(conditions = {})
      @conditions = conditions
    end

    def validate(input)
      unless input.respond_to?(:size)
        return Dzl::ValueOrError.new(
          e: :cannot_validate_size
        )
      end

      valid = @conditions.all? do |op, n|
        input.size.send(op, n)
      end

      if valid
        Dzl::ValueOrError.new(v: input)
      else
        Dzl::ValueOrError.new(e: :size_validation_failed)
      end
    end

    [:==, :<=, :>=, :<, :>].each do |op|
      define_method(op) do |n|
        @conditions[op] = n
      end
    end

    def clone
      dup_conditions = @conditions.clone
      self.class.new(dup_conditions)
    end
  end
end