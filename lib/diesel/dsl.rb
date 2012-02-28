module Diesel::DSL; end

require 'diesel/parameter'
require 'diesel/parameter_block'
require 'diesel/endpoint'

module Diesel::DSL
  # Router stores everything (per class) here
  def _router
    @_router ||= Diesel::Router.new
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
    raise ArgumentError unless opts.is_a?(Hash)

    _router[:endpoints][name] = Endpoint.new(name, opts, _router)
    _router.call_with_subject(Proc.new, _router[:endpoints][name]) if block_given?
  end

  def defaults(&block)
    raise ArgumentError unless block_given?
    # TODO
  end

  # TODO rename this method
  # TODO actually import this pblock into other pblocks
  def global_pblock(&block)
    raise ArgumentError unless block_given?
    pblock(:__default, &block)
  end
end