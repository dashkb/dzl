class Distil::Validator
  def validate(input)
    raise "You must implement #validate in your Distil::Validator subclass"
  end
end

module Distil::Validators; end

require 'distil/validators/size'
require 'distil/validators/value'