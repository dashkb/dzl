module Diesel::DSL
  # Router stores everything (per class) here
  def _router
    if !@_router
      @_router = {
        pblocks: {},
        endpoints: {},
        stack: []
      }

      # This is no ordinary hash.
      def @_router.call_with_subject(proc, subject)
        self[:stack].push(subject)
        proc.call
        self[:stack].pop
      end
    end

    @_router
  end

  def _subject
    _router[:stack].last
  end

  # If a DSL user calls an undefined method in a block,
  # we want to try to call it on the object on top
  # of our stack
  def method_missing(m, *args, &block)
    if _subject && _subject.respond_to?(m)
      _subject.send(m, *args, &block)
    else
      raise "Diesel could not find a responder for #{m}, stack is #{_router[:stack].reverse}"
    end
  end

  def app_name(name = nil)
    _router[:app_name] ||= name
  end

  def pblock(name, opts = {})
    raise ArgumentError unless name.is_a?(Symbol) &&
                               opts.is_a?(Hash)   &&
                               block_given?

    
    _router[:pblocks][name] = ParameterBlock.new(name, opts, _router)
    _router.call_with_subject(Proc.new, _router[:pblocks][name])
  end

  def endpoint(name, opts = {})
    raise ArgumentError unless name.is_a?(Symbol) &&
                               opts.is_a?(Hash)   &&
                               block_given?

    _router[:endpoints][name] = Endpoint.new(name, opts, _router)
    _router.call_with_subject(Proc.new, _router[:endpoints][name].pblock)
  end
end