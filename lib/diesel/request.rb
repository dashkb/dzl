class Diesel::Request < Rack::Request
  attr_accessor :silent

  def initialize(env)
    super(env)

    @endpoints = Hash.new({})
  end

  def headers
    @headers ||= begin
      env.each_with_object({}) do |env_pair, headers|
        k, v = env_pair
        if header = (/HTTP_(.+)/.match(k.upcase.gsub('-', '_'))[1]) rescue nil
          headers[header.downcase] = v
        end
      end
    end
  end

  def params
    @params ||= super
  end

  def overwrite_headers(new_headers)
    @headers = new_headers
  end

  def overwrite_params(new_params)
    @params = new_params
  end

  def handle_with_endpoint(endpoint)
    overwrite_params(@endpoints[endpoint][:params])
    overwrite_headers(@endpoints[endpoint][:headers])
    endpoint.handle(self).finish
  end

  def params_and_headers_for_endpoint(endpoint, params_and_headers = nil)
    if params_and_headers
      raise ArgumentError unless params_and_headers.is_a?(Hash) &&
                                 params_and_headers.has_key?(:params) &&
                                 params_and_headers.has_key?(:headers)

      @endpoints[endpoint].merge!(params_and_headers)
    else
      @endpoints[endpoint].slice(:params, :headers)
    end
  end

  def silent?
    @silent == true
  end
end