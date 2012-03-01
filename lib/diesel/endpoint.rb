require 'diesel/endpoint_dsl'

class Diesel::Endpoint
  include Diesel::EndpointDSL
  attr_reader :pblock

  def initialize(route, opts, router)
    @route   = route
    @opts   = opts
    @router  = router
    @pblock  = Diesel::ParameterBlock.new(:anonymous, {}, @router)

    analyze_route
  end

  def as_json(opts=nil)
    {
      opts: @opts,
      pblock: @pblock
    }
  end

  def handle(request = nil)
    if block_given?
      @handler = Proc.new
    elsif request && @handler.is_a?(Proc)
      Diesel::ResponseContext.new(self, request, @handler).respond
    else
      raise 'nope'
    end
  end

  def params_and_errors(request)
    route_params = extract_route_parameters(request.path)
    return [{}, {:_routing => :route_match_fail}] if route_params.nil?
    params = request.params.merge(route_params).symbolize_keys
    errors = pblock.validate(params)
    [params, errors]
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
      params[1..-1].each {|p| @pblock.required(p.to_sym, in_path: true)}
    end

    @route_splits = @route.split('/')
    @route_splits.delete('')
  end
end