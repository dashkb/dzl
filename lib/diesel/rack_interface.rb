
require 'rack'
require 'diesel/request'
require 'ruby-prof'

module Diesel::RackInterface
  PROFILE_REQUESTS = false

  def call(env)
    out = nil
    RubyProf.start if PROFILE_REQUESTS
    begin
      out = @_router.handle_request(Diesel::Request.new(env))
    rescue StandardError => e
      response = Rack::Response.new
      response.headers['Content-Type'] = 'application/json'

      begin
        status, errors = JSON.parse(e.to_s) # TODO subclass StandardError
        response.status = status;
      rescue JSON::ParserError
        response.write({
          status: 500,
          error_class: e.class.to_s,
          errors: e.to_s,
          trace: e.backtrace
        }.to_json)
      else
        response.write({
          status: status,
          error_class: 'Diesel Runtime Error',
          errors: errors,
          trace: e.backtrace
        }.to_json)
      end

      out = response.finish
    end

    if PROFILE_REQUESTS
      result = RubyProf.stop
      printer = RubyProf::GraphHtmlPrinter.new(result)
      printer.print(File.open('/Projects/diesel/profile.html', 'w'))
    end

    out
  end
end