class Diesel::DSL::Endpoint
  attr_reader :pblock

  def initialize(route, opts, router)
    @route   = route
    @opts   = opts
    @router  = router
    @pblock  = Diesel::DSL::ParameterBlock.new(:anonymous, {}, @router)

    analyze_route
  end

  def analyze_route
    @route = "/#{@route}" if @route.is_a?(Symbol)

    if params = /\/:([^\/]+)/.match(@route)
      params[1..-1].each {|p| @pblock.required(p.to_sym, in_path: true)}
    end

    @route_splits = @route.split('/')
    @route_splits.delete('')
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
      Diesel::ResponseContext.new(request, @handler).respond
    end
  end

  def respond_to_request?(request)
    request.path == @route                    ||
    path_with_params_matches?(request.path)
  end

  def path_with_params_matches?(path)
    path_splits = path.split('/')
    path_splits.delete('')

    return false if path_splits.size != @route_splits.size

    # Does each route split match the corresponding
    # path split in the request?
    @route_splits.all? do |route_split|
      path_split = path_splits.shift
      # Cast param to integer if it is one # HACKY
      path_split = path_split.to_i if path_split.to_i.to_s == path_split

      if !route_split.starts_with?(':')
        path_split == route_split
      else
        # Hand off validation to the parameter
        param = route_split[1..-1].to_sym
        @pblock.params[param].valid?(path_split)
      end
    end
  end

  # Delegate to our pblock if we don't answer a method
  @@m_respond_to = self.instance_method(:respond_to?)
  def respond_to?(m)
    @@m_respond_to.bind(self).call(m) || @pblock.respond_to?(m)
  end

  def method_missing(m, *args, &block)
    if @pblock.respond_to?(m)
      @pblock.send(m, *args, &block)
    else
      raise "the buck stops here"
    end
  end
end