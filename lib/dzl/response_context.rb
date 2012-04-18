require 'dzl/response_context/request_helpers'

class Dzl::ResponseContext
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
    __build_response_with_defaults__
  end

  def logger
    @logger ||= @endpoint.router.app.logger
  end

  def __respond__
    @endpoint.hooks[:after_validate].each do |proc|
      self.instance_exec(&proc)
    end

    value = @handler ? self.instance_exec(&@handler) : self.instance_exec(&@@default_handler)

    unless @response.body.present?
      @response.write(value)
    end

    @response
  rescue Dzl::ValidationError => e
    @response.status = 404
    @response.write({
      errors: {
        @endpoint.route => e.data
      }
    }.to_json)
    @response
  end

  def __build_response_with_defaults__
    @response = Rack::Response.new

    if ct = @endpoint.router.defaults[:content_type]
      @response['Content-Type'] = ct
    end
  end
end