require 'dzl/dsl_proxies/protection'

class Dzl::RespondWithHTTPBasicChallenge < StandardError; end
class Dzl::RespondWithInvalidAPIKey < StandardError; end

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
        # Invalid basic auth credentials
        unless @auth.credentials[0] == @opts[:http_basic][:username] &&
               @auth.credentials[1] == @opts[:http_basic][:password]
          return Dzl::ValueOrError.new(e: :invalid_http_basic_credentials)
        end
        # No basic auth credentials provided
      else
        return Dzl::ValueOrError.new(e: :no_http_basic_credentials)
      end
    end

    if @opts[:api_key].present?
      api_key_header = @opts[:api_key][:header]
      request_key = request.headers[api_key_header]

      if request_key
        # Invalid API key provided
        if (valid_keys = @opts[:api_key][:valid_keys]).present?
          unless valid_keys.include? request_key
            return Dzl::ValueOrError.new(e: :invalid_api_key)
          end
        elsif (key_proc = @opts[:api_key][:validate_with]).present?
          unless key_proc.call(request_key)
            return Dzl::ValueOrError.new(e: :invalid_api_key)
          end
        end
      # No API key provided
      else
        return Dzl::ValueOrError.new(e: :no_api_key)
      end
    end

    # Auth passed
    return Dzl::ValueOrError.new(v: nil)
  end
end
