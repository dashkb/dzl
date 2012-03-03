module Diesel::DSL; end
module Diesel::DSLSubjects; end
module Diesel::DSLProxies; end

require 'diesel/dsl_proxy'
require 'diesel/dsl_subject'
require 'diesel/dsl_subjects/parameter'
require 'diesel/dsl_subjects/parameter_block'
require 'diesel/dsl_subjects/endpoint'

module Diesel::DSL
  # Router stores everything (per class) here
  def _router
    @_router ||= Diesel::Router.new
  end

  # If a DSL user calls an undefined method in a block,
  # we want to try to call it on the object on top
  # of our stack
  alias_method :orig_mm, :method_missing
  def method_missing(m, *args, &block)
    subject = _router.subject
    if subject && subject.dsl_proxy && subject.dsl_proxy.respond_to?(m)
      subject.dsl_proxy.send(m, *args, &block)
    else
      raise "Diesel could not find a responder for #{m}, stack is #{_router[:stack].reverse}"
    end
  end

  alias_method :orig_respond_to?, :respond_to?
  def respond_to?(m)
    orig_respond_to?(m) || (_router.subject &&
                           _router.subject.dsl_proxy &&
                           _router.subject.dsl_proxy.respond_to?(m))
  end

  def pblock(name, opts = {})
    raise ArgumentError unless name.is_a?(Symbol) &&
                               opts.is_a?(Hash)   &&
                               block_given?

    
    pb = Diesel::DSLSubjects::ParameterBlock.new(name, opts, _router)
    _router.add_pblock(pb)
    _router.call_with_subject(Proc.new, pb)
  end

  def endpoint(route, opts = {})
    raise ArgumentError unless opts.is_a?(Hash)

    ept = Diesel::DSLSubjects::Endpoint.new(route, opts, _router)
    _router.add_endpoint(ept)
    _router.call_with_subject(Proc.new, ept) if block_given?
  end

  def defaults(&block)
    raise ArgumentError unless block_given?
    # TODO
  end

  # TODO rename this method
  def global_pblock(&block)
    raise ArgumentError unless block_given?
    pblock(:__default, &block)
  end
end