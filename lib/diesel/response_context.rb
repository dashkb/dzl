class Diesel::ResponseContext
  attr_reader :request, :response

  def initialize(request, handler)
    @request  = request
    @response = Rack::Response.new
    @handler  = handler
  end

  def respond
    value = self.instance_exec(&@handler)

    unless @response.body.present?
      @response.write(value)
    end

    @response
  end
end