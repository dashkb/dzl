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
    response = Rack::Response.new
    response['Content-Type'] = 'application/json'

    endpoint = find_endpoint(request)

    response.finish
  end

  def find_endpoint(request)
    endpoint = routes.find do |route, endpoint|
      endpoint.respond_to_request?(request)
    end

    raise 'TODO 404' unless endpoint

    puts "Would handle request with #{endpoint}"
  end
end