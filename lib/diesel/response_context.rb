require 'diesel/response_context/request_helpers'

class Diesel::ResponseContext
  include RequestHelpers
  attr_reader :request, :response, :endpoint

  @@default_handler = Proc.new do
    response['Content-Type'] = 'application/json'
    {
      headers: headers,
      params: params
    }.to_json
  end

  def initialize(endpoint, request, handler = nil)
    @request  = request
    @response = Rack::Response.new
    @endpoint = endpoint
    @handler  = handler
  end

  def respond
    value = @handler ? self.instance_exec(&@handler) : self.instance_exec(&@@default_handler)

    unless @response.body.present?
      @response.write(value)
    end

    @response
  end
end