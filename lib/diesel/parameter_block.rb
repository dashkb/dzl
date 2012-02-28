class Diesel::DSL::ParameterBlock
  attr_accessor :name, :opts, :params

  def initialize(name, opts, router)
    @name   = name
    @opts   = opts
    @router = router
    @params = {}
  end

  def parameter(*names)
    opts = names.last.is_a?(Hash) ? names.pop : {required: false}

    names.each do |name|
      if @params[name]
        # Don't clobber params we already know about
        @params[name].overwrite_opts(opts)
      else
        @params[name] = Diesel::DSL::Parameter.new(name, opts)
      end

      @router.call_with_subject(Proc.new, @params[name]) if block_given?
    end
  end
  alias_method :param, :parameter

  def required(*names, &block)
    opts = names.last.is_a?(Hash) ? names.pop : {}
    parameter(*names, opts.merge(required: true), &block)
  end

  def optional(*names, &block)
    opts = names.last.is_a?(Hash) ? names.pop : {}
    parameter(*names, opts.merge(required: false), &block)
  end

  def required_header(*names, &block)
    opts = names.last.is_a?(Hash) ? names.pop : {}
    required(*names, opts.merge(header: true), &block)
  end

  def optional_header(*names, &block)
    opts = names.last.is_a?(Hash) ? names.pop : {}
    optional(*names, opts.merge(header: true), &block)
  end

  def forbid(*names)
    names.each do |name|
      @params.delete(name)
    end
  end

  def import_pblock(*pblocks)
    pblocks.each do |pblock|
      @router[:pblocks][pblock].params.each do |name, param|
        @params[name] = param.dup
      end
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