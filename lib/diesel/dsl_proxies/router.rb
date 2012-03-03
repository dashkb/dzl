class Diesel::DSLProxies::Router < Diesel::DSLProxy
  def pblock(name, opts = {})
    raise ArgumentError unless name.is_a?(Symbol) &&
                               opts.is_a?(Hash)   &&
                               block_given?

    
    pb = Diesel::DSLSubjects::ParameterBlock.new(name, opts, @subject)
    @subject.add_pblock(pb)
    @subject.call_with_subject(Proc.new, pb)
  end

  def endpoint(route, opts = {})
    raise ArgumentError unless opts.is_a?(Hash)

    ept = Diesel::DSLSubjects::Endpoint.new(route, opts, @subject)
    @subject.add_endpoint(ept)
    @subject.call_with_subject(Proc.new, ept) if block_given?
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

  alias_method :orig_respond_to?, :respond_to?
  def respond_to?(m)
    orig_respond_to?(m) || (@subject.subject && 
                            @subject.subject.dsl_proxy.respond_to?(m))
  end

  def method_missing(m, *args, &block)
    if orig_respond_to?(m)
      super.method_missing(m, *args, &block)
    else
      @subject.subject.dsl_proxy.send(m, *args, &block)
    end
  end
end