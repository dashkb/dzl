require 'diesel/dsl_proxies/endpoint'

class Diesel::DSLSubjects::Endpoint < Diesel::DSLSubject
  attr_reader :pblock, :route_regex

  def initialize(route, opts, router)
    @route   = route
    @opts   = opts
    @router  = router
    @pblock  = Diesel::DSLSubjects::ParameterBlock.new(:anonymous, {}, @router)
    @pblock.dsl_proxy.import_pblock(:__default)
    @dsl_proxy = Diesel::DSLProxies::Endpoint.new(self)

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
    elsif request
      Diesel::ResponseContext.new(self, request, @handler).respond
    else
      raise [500, "handle in #{@route}: block? #{block_given?}, request: #{request}, handler: #{@handler}"].to_json
    end
  end

  def params_and_errors(request)
    route_params = extract_route_parameters(request.path)
    return [{}, {:_routing => :route_match_fail}] if route_params.nil?

    params = {
      params: request.params.merge(route_params).symbolize_keys,
      headers: request.headers.symbolize_keys
    }

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
      params[1..-1].each {|p| @pblock.dsl_proxy.required(p.to_sym, in_path: true)}
    end

    @route_splits = @route.split('/')
    @route_splits.delete('')

    route_parts = @route.split('/').select{|s| not s.empty?}

    route_regex_string = route_parts.collect do |route_part|
      route_part.starts_with?(':') ? "/.*?" : "/#{route_part}"
    end.push('$').join('')

    @route_regex = Regexp.new(route_regex_string)
  end
end