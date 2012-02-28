module Diesel::Validators
  class Size
    def initialize
      @conditions = []
    end

    [:==, :<=, :>=, :<, :>].each do |op|
      define_method(op) do |n|
        @conditions << [op, n]
      end
    end
  end
end