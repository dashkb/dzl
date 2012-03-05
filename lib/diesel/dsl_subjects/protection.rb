require 'diesel/dsl_proxies/protection'

class Diesel::RespondWithHTTPBasicChallenge < StandardError; end

class Diesel::DSLSubjects::Protection < Diesel::DSLSubject
  def initialize
    super
    @dsl_proxy = Diesel::DSLProxies::Protection.new(self)
  end

  def allow?(parandidates, request)
    params = parandidates[:params]
    headers = parandidates[:headers]

    if @opts[:http_basic].present?
      @auth = Rack::Auth::Basic::Request.new(request.env)
      if @auth.provided? && @auth.basic? && @auth.credentials
        unless @auth.credentials[0] == @opts[:http_basic][:username] &&
               @auth.credentials[1] == @opts[:http_basic][:password]
          Diesel::ValueOrError.new(e: :invalid_http_basic_credentials)
        else
          Diesel::ValueOrError.new(v: nil)
        end
      else
        Diesel::ValueOrError.new(e: :no_http_basic_credentials)
      end
    else
      Diesel::ValueOrError.new(v: nil)
    end
  end
end