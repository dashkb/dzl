
require 'rack'
require 'diesel/request'
require 'ruby-prof'

module Diesel::RackInterface
  PROFILE_REQUESTS = false

  def call(env)
    out = nil
    request = nil
    start_time = Time.now
    start_profile if PROFILE_REQUESTS
    begin
      request = Diesel::Request.new(env)
      out = __router.handle_request(request)
    rescue Diesel::RespondWithHTTPBasicChallenge
      out = respond_with_http_basic_challenge
    rescue StandardError => e
      out = respond_with_error_handler(e)
    end

    stop_profiling_and_print if PROFILE_REQUESTS
    log_request(request, out, (Time.now - start_time))
    out
  end

  def respond_with_http_basic_challenge
    response = Rack::Response.new
    response['WWW-Authenticate'] = %(Basic realm="Diesel HTTP Basic")
    response.status = 401
    response.headers['Content-Type'] = 'text/html'
    response.write("Not Authorized\n")
    out = response.finish
  end

  def respond_with_error_handler(e)
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

  def start_profile
    RubyProf.start
  end

  def stop_profiling_and_print
    result = RubyProf.stop
    printer = RubyProf::GraphHtmlPrinter.new(result)
    printer.print(
      File.open('/Projects/diesel/profile.html', 'w'),
      min_percent: 5
    )
  end

  def log_request(request, response, seconds)
    Diesel.logger.info "#{request.request_method} #{request.path}"
    Diesel.logger.info "PARAMS: #{request.params}"
    Diesel.logger.info "#{response[0]} in #{seconds}s"
  end
end