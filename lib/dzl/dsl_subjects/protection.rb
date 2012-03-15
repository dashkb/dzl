require 'dzl/dsl_proxies/protection'

class Dzl::RespondWithHTTPBasicChallenge < StandardError; end

class Dzl::DSLSubjects::Protection < Dzl::DSLSubject
  def initialize
    super
    @dsl_proxy = Dzl::DSLProxies::Protection.new(self)
  end

  def allow?(parandidates, request)
    params = parandidates[:params]
    headers = parandidates[:headers]

    if @opts[:http_basic].present?
      @auth = Rack::Auth::Basic::Request.new(request.env)
      if @auth.provided? && @auth.basic? && @auth.credentials
        unless @auth.credentials[0] == @opts[:http_basic][:username] &&
               @auth.credentials[1] == @opts[:http_basic][:password]
          Dzl::ValueOrError.new(e: :invalid_http_basic_credentials)
        else
          Dzl::ValueOrError.new(v: nil)
        end
      else
        Dzl::ValueOrError.new(e: :no_http_basic_credentials)
      end
    else
      Dzl::ValueOrError.new(v: nil)
    end
  end
end