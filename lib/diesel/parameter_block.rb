class Diesel::DSL::ParameterBlock
  attr_accessor :name, :opts, :params

  def initialize(name, opts, router)
    @name   = name
    #@opts   = opts
    @router = router
    @params = {}
  end

  def parameter(name, opts)
    if @params[name]
      # Don't clobber params we already know about
      @params[name].overwrite_opts(opts)
    else
      @params[name] = Diesel::DSL::Parameter.new(name, opts)
    end

    @router.call_with_subject(Proc.new, @params[name]) if block_given?
  end

  def required(name, opts = {}, &block)
    parameter(name, opts.merge(required: true), &block)
  end

  def optional(name, opts = {}, &block)
    parameter(name, opts.merge(required: false), &block)
  end

  def import_pblock(pblock)
    @router[:pblocks][pblock].params.each do |name, param|
      @params[name] = param.dup
    end
  end

  def to_s
    "pblock:#{name}"
  end

  def as_json(opts=nil)
    {
      opts: @opts,
      params: @params
    }
  end
end