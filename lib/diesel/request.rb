class Diesel::Request < Rack::Request
  def initialize(env)
    super(env)
  end

  def headers
    @headers ||= begin
      env.each_with_object({}) do |env_pair, headers|
        k, v = env_pair
        if header = (/HTTP_(.+)/.match(k.upcase.gsub('-', '_'))[1]) rescue nil
          headers[header] = v
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
end