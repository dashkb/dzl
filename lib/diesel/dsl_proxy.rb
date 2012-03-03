class Diesel::DSLProxy
  def initialize(subject)
    raise ArgumentError unless subject
    @subject = subject
  end
end

module Diesel::DSLProxies; end