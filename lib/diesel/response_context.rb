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
    @endpoint = endpoint
    @handler  = handler
    build_response_with_defaults
  end

  def respond
    value = @handler ? self.instance_exec(&@handler) : self.instance_exec(&@@default_handler)

    unless @response.body.present?
      @response.write(value)
    end

    @response
  end

  def build_response_with_defaults
    @response = Rack::Response.new

    if ct = @endpoint.router.defaults[:content_type]
      @response['Content-Type'] = ct
    end
  end
end