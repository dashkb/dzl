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
    endpoint = routes.find do |route, endpoint|
      endpoint.respond_to_request?(request)
    end[1] rescue nil

    endpoint ? endpoint : raise('TODO 404')
  end
end