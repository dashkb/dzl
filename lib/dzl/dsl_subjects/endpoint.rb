require 'dzl/dsl_proxies/endpoint'

class Dzl::DSLSubjects::Endpoint < Dzl::DSLSubject
  attr_reader :pblock, :route_regex, :route, :router, :hooks
  attr_accessor :handler
  include Dzl::EndpointDoc

  def initialize(route, opts, router)
    @route   = route
    @opts    = opts
    @router  = router
    @pblock  = Dzl::DSLSubjects::ParameterBlock.new(:anonymous, {}, @router)
    @pblock.dsl_proxy.import_pblock(:__default)
    @dsl_proxy = Dzl::DSLProxies::Endpoint.new(self)
    @hooks   = {
      after_validate: []
    }

    analyze_route
  end

  def as_json(opts=nil)
    {
      opts: @opts,
      pblock: @pblock
    }
  end

  def handle(request)
    request.silent = true if @opts[:silent]
    Dzl::ResponseContext.new(self, request, @handler).__respond__
  end

  def validate(request)
    unless @opts[:request_methods].include?(request.request_method.downcase.to_sym)
      return Dzl::ValueOrError.new(e: :request_method_not_supported)
    end

    route_params = extract_route_parameters(request.path)
    params = {
      params: request.params.merge(route_params).symbolize_keys,
      headers: request.headers.symbolize_keys
    }

    pblock.validate(params, request)
  end

  def extract_route_parameters(path)
    path_splits = path.split('/')
    path_splits.delete('')

    return nil if path_splits.size != @route_splits.size

    Hash[
      *@route_splits.collect do |rsplit|
        psplit = path_splits.shift
        next unless rsplit.starts_with?(':')
        [rsplit[1..-1].to_sym, psplit]
      end.compact.flatten
    ]
  end

  private
  def analyze_route
    @route = "/#{@route}" if @route.is_a?(Symbol)

    if params = /\/:([^\/]+)/.match(@route)
      params[1..-1].each {|p| @pblock.dsl_proxy.required(p.to_sym, in_path: true)}
    end

    @route_splits = @route.split('/').select{|s| not s.empty?}

    route_regex_string = @route_splits.collect do |route_part|
      route_part.starts_with?(':') ? "/[a-zA-Z0-9._~-]+" : "/#{route_part}"
    end.push('/?$').join('')

    @route_regex = Regexp.new('^' + route_regex_string)
  end
end
