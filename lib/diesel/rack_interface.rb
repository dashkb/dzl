module Diesel::RackInterface
  def call(env)
    @_router.handle_request(Rack::Request.new(env))
  end
end