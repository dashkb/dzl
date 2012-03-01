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
    response = endpoint.handle(request)
    response.finish
  end

  def find_endpoint(request)
    errors = {}
    endpoint = routes.find do |route, endpoint|
      params, _errors = endpoint.params_and_errors(request)
      if _errors.empty?
        # use our validated/transformed/params
        request.params.merge!(params).symbolize_keys!
        true
      else
        errors[route] = _errors
        false
      end
    end[1] rescue nil

    endpoint || raise([404, errors].to_json)
  end
end