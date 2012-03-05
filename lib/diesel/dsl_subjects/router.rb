require 'diesel/dsl_proxies/router'

class Diesel::DSLSubjects::Router < Diesel::DSLSubject
  attr_reader :pblocks

  def initialize
    @pblocks = {}
    @endpoints_by_route = {}
    @stack = []
    @dsl_proxy = Diesel::DSLProxies::Router.new(self)
  end

  def call_with_subject(proc, subject)
    @stack.push(subject)
    proc.call
    @stack.pop
  end

  def subject
    @stack.last
  end

  def routes
    @endpoints_by_route.keys
  end

  def endpoints
    @endpoints = @endpoints_by_route.values.flatten
  end

  def add_endpoint(ept)
    @endpoints_by_route[ept.route] ||= []
    @endpoints_by_route[ept.route] << ept
  end

  def pblocks
    @pblocks
  end

  def add_pblock(pb)
    @pblocks[pb.name] = pb
  end

  def as_json(opts=nil)
    @endpoints
  end

  def handle_request(request)
    endpoint = find_endpoint(request)
    response = request.handle_with_endpoint(endpoint)
  end

  def find_endpoint(request)
    errors = {}
    raise([404, {}].to_json) if routes.empty?

    endpoint = endpoints.find do |endpoint|
      if request.path.match(endpoint.route_regex)
        validation = endpoint.validate(request)
        if validation.value?
          # use our validated/transformed/params
          request.params_and_headers_for_endpoint(
            endpoint,
            validation.value
          )
          true
        else
          errors[endpoint.route] = validation.error
          false
        end
      end
    end

    if !errors.empty? &&
        errors.values.all? {|v| v == :no_http_basic_credentials || v == :invalid_http_basic_credentials}
      raise Diesel::RespondWithHTTPBasicChallenge
    end

    endpoint || raise([404, errors].to_json)
  end
end