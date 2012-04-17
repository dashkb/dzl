require 'dzl/dsl_proxies/router'
require 'dzl/dsl_subjects/defaults'

class Dzl::DSLSubjects::Router < Dzl::DSLSubject
  include Dzl::RouterDoc
  attr_reader :pblocks, :defaults_dslsub, :defaults, :app

  def initialize(app)
    @pblocks = {}
    @endpoints_by_route = {}
    @stack = []
    @scope = []
    @defaults = {
      array_separator: ' '
    }
    @defaults_dslsub = Dzl::DSLSubjects::Defaults.new(self)
    @dsl_proxy = Dzl::DSLProxies::Router.new(self)
    @app = app
  end

  def call_with_subject(proc, subject)
    @stack.push(subject)
    proc.call
    @stack.pop
  end

  def __evil_subject_pop
    @stack.pop
  end

  def subject
    @stack.last
  end

  def call_with_scope(proc, scope)
    @scope.push(scope)
    proc.call
    @scope.pop
  end

  def scope
    @scope.join
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
    raise Dzl::NotFound if routes.empty?

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
        errors.values.any? {|v| v == :no_http_basic_credentials || v == :invalid_http_basic_credentials}
      raise Dzl::RespondWithHTTPBasicChallenge
    end

    endpoint || raise(Dzl::NotFound.new(errors))
  end
  
end