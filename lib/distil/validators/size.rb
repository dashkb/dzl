module Distil::Validators
  class Size < Distil::Validator
    attr_reader :conditions
    def initialize
      @conditions = []
    end

    def validate(input)
      unless input.respond_to?(:size)
        return Distil::ValueOrError.new(
          e: :cannot_validate_size
        )
      end

      valid = @conditions.all? do |op, n|
        input.size.send(op, n)
      end

      if valid
        Distil::ValueOrError.new(v: input)
      else
        Distil::ValueOrError.new(e: :size_validation_failed)
      end
    end

    [:==, :<=, :>=, :<, :>].each do |op|
      define_method(op) do |n|
        @conditions << [op, n]
      end
    end
  end
end