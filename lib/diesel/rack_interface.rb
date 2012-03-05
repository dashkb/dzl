
require 'rack'
require 'diesel/request'
require 'ruby-prof'

module Diesel::RackInterface
  PROFILE_REQUESTS = false

  def call(env)
    out = nil
    start_time = Time.now
    RubyProf.start if PROFILE_REQUESTS
    begin
      request = Diesel::Request.new(env)
      Diesel.logger.info "#{request.request_method} #{request.path}"
      Diesel.logger.info request.params.inspect
      out = __router.handle_request(request)
    rescue Diesel::RespondWithHTTPBasicChallenge
      response = Rack::Response.new
      response['WWW-Authenticate'] = %(Basic realm="Diesel HTTP Basic")
      response.status = 401
      response.headers['Content-Type'] = 'text/html'
      response.write("Not Authorized\n")
      out = response.finish
    rescue StandardError => e
      response = Rack::Response.new
      response.headers['Content-Type'] = 'application/json'

      begin
        status, errors = JSON.parse(e.to_s) # TODO subclass StandardError
        response.status = status;
      rescue JSON::ParserError
        response.status = 500
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
      printer.print(
        File.open('/Projects/diesel/profile.html', 'w'),
        min_percent: 5
      )
    end

    Diesel.logger.info "#{out[0]} complete in #{Time.now - start_time}s"

    out
  end
end