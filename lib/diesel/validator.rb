class Diesel::Validator
  def validate(input)
    raise "You must implement #validate in your Diesel::Validator subclass"
  end
end

module Diesel::Validators; end

require 'diesel/validators/size'
require 'diesel/validators/value'