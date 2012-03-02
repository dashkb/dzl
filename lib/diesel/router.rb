class Diesel::Router < Hash
  def initialize
    super

    merge!({
      pblocks: {},
      endpoints: {},
      stack: []
    })
  end

  def call_with_subject(proc, subject)
    self[:stack].push(subject)
    proc.call
    self[:stack].pop
  end

  def routes
    self[:endpoints]
  end

  def pblocks
    self[:pblocks]
  end

  def as_json(opts=nil)
    routes
  end

  def handle_request(request)
    endpoint = find_endpoint(request)
    response = request.handle_with_endpoint(endpoint)
  end

  def find_endpoint(request)
    errors = {}
    endpoint = routes.find do |route, endpoint|
      if request.path.match(endpoint.route_regex)
        params_and_headers, _errors = endpoint.params_and_errors(request)
        if _errors.empty?
          # use our validated/transformed/params
          request.params_and_headers_for_endpoint(
            endpoint,
            params_and_headers
          )
          true
        else
          errors[route] = _errors
          false
        end
      end
    end

    route, endpoint = endpoint if endpoint

    endpoint || raise([404, errors].to_json)
  end
end