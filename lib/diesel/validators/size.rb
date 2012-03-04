class Diesel::Validator
  def validate(input)
    raise "You must implement #validate in your Diesel::Validator subclass"
  end
end # TODO

module Diesel::Validators
  class Size < Diesel::Validator
    def initialize
      @conditions = []
    end

    def validate(input)
      unless input.respond_to?(:size)
        return Diesel::ValueOrError.new(
          e: :cannot_validate_size
        )
      end

      valid = @conditions.all? do |op, n|
        input.size.send(op, n)
      end

      if valid
        Diesel::ValueOrError.new(v: input)
      else
        Diesel::ValueOrError.new(e: :size_validation_failed)
      end
    end

    [:==, :<=, :>=, :<, :>].each do |op|
      define_method(op) do |n|
        @conditions << [op, n]
      end
    end
  end
end