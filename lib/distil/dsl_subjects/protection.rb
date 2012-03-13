require 'distil/dsl_proxies/protection'

class Distil::RespondWithHTTPBasicChallenge < StandardError; end

class Distil::DSLSubjects::Protection < Distil::DSLSubject
  def initialize
    super
    @dsl_proxy = Distil::DSLProxies::Protection.new(self)
  end

  def allow?(parandidates, request)
    params = parandidates[:params]
    headers = parandidates[:headers]

    if @opts[:http_basic].present?
      @auth = Rack::Auth::Basic::Request.new(request.env)
      if @auth.provided? && @auth.basic? && @auth.credentials
        unless @auth.credentials[0] == @opts[:http_basic][:username] &&
               @auth.credentials[1] == @opts[:http_basic][:password]
          Distil::ValueOrError.new(e: :invalid_http_basic_credentials)
        else
          Distil::ValueOrError.new(v: nil)
        end
      else
        Distil::ValueOrError.new(e: :no_http_basic_credentials)
      end
    else
      Distil::ValueOrError.new(v: nil)
    end
  end
end