module Diesel::RackInterface
  def call(env)
    begin
      @_router.handle_request(Rack::Request.new(env))
    rescue StandardError => e
      response = Rack::Response.new
      response.headers['Content-Type'] = 'application/json'
      response.status = 500;

      response.write({
        status: 500,
        error_class: e.class.to_s,
        error_info: JSON.parse(e.to_s),
        trace: e.backtrace
      }.to_json)

      response.finish
    end
  end
end