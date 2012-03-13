class Distil::DSLProxy
  def initialize(subject)
    raise ArgumentError unless subject
    @subject = subject
  end
end

module Distil::DSLProxies; end