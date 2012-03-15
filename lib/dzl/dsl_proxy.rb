class Dzl::DSLProxy
  def initialize(subject)
    raise ArgumentError unless subject
    @subject = subject
  end
end

module Dzl::DSLProxies; end