require 'diesel/response_context/request_helpers'

class Diesel::ResponseContext
  include RequestHelpers
  attr_reader :request, :response, :endpoint

  def initialize(endpoint, request, handler)
    @request  = request
    @response = Rack::Response.new
    @endpoint = endpoint
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