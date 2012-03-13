class Distil::DSLProxies::Router < Distil::DSLProxy
  REQUEST_METHODS = [:get, :post, :put, :delete, :options]

  def pblock(name, opts = {})
    raise ArgumentError unless name.is_a?(Symbol) &&
                               opts.is_a?(Hash)   &&
                               block_given?

    
    pb = Distil::DSLSubjects::ParameterBlock.new(name, opts, @subject)
    @subject.add_pblock(pb)
    @subject.call_with_subject(Proc.new, pb)
  end
  alias_method :parameters, :pblock

  def endpoint(route, *request_methods)
    request_methods = [:get] if request_methods.empty?
    request_methods.uniq!

    raise ArgumentError unless request_methods.all? {|m| REQUEST_METHODS.include?(m)}
    opts = {
      request_methods: request_methods
    }

    ept = Distil::DSLSubjects::Endpoint.new(route, opts, @subject)
    @subject.add_endpoint(ept)
    @subject.call_with_subject(Proc.new, ept) if block_given?
  end

  def defaults(&block)
    raise ArgumentError unless block_given?

    @subject.call_with_subject(Proc.new, @subject.defaults_dslsub)
  end

  REQUEST_METHODS.each do |m|
    define_method(m) do |route, *request_methods, &block|
      request_methods << m
      endpoint(route, *request_methods, &block)
    end
  end

  def global_parameters(&block)
    raise ArgumentError unless block_given?
    pblock(:__default, &block)
  end
  alias_method :global_pblock, :global_parameters

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