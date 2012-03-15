class Dzl::Validator
  def validate(input)
    raise "You must implement #validate in your Dzl::Validator subclass"
  end
end

module Dzl::Validators; end

require 'dzl/validators/size'
require 'dzl/validators/value'