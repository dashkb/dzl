module Diesel::RackInterface
  def call(env)
    begin
      @_router.handle_request(Rack::Request.new(env))
    rescue StandardError => e
      response = Rack::Response.new
      response.headers['Content-Type'] = 'application/json'
      status, errors = JSON.parse(e.to_s) # TODO subclass StandardError
      response.status = status;

      response.write({
        status: status,
        error_class: e.class.to_s,
        errors: errors,
        trace: e.backtrace
      }.to_json)

      response.finish
    end
  end
end