module Diesel::EndpointDSL
  def handle(request = nil)
    if block_given?
      @handler = Proc.new
    elsif request && @handler.is_a?(Proc)
      Diesel::ResponseContext.new(request, @handler).respond
    end
  end
end