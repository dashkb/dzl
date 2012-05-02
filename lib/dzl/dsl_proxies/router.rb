class Dzl::DSLProxies::Router < Dzl::DSLProxy
  REQUEST_METHODS = [:get, :post, :put, :delete, :options]

  def pblock(name, opts = {})
    raise ArgumentError unless name.is_a?(Symbol) &&
                               opts.is_a?(Hash)   &&
                               block_given?

    
    pb = Dzl::DSLSubjects::ParameterBlock.new(name, opts, @subject)
    @subject.add_pblock(pb)
    @subject.call_with_subject(Proc.new, pb)
  end
  alias_method :parameters, :pblock

  def scope(path)
    raise ArgumentError unless block_given?
    raise ArgumentError.new("scope must start with a '/'") unless path.starts_with?('/')

    @subject.call_with_scope(Proc.new, path)
  end
  alias_method :namespace, :scope

  def endpoint(route, *request_methods)
    request_methods = [:get] if request_methods.empty?
    request_methods.uniq!

    raise ArgumentError unless request_methods.all? {|m| REQUEST_METHODS.include?(m)}
    opts = {
      request_methods: request_methods
    }

    ept = Dzl::DSLSubjects::Endpoint.new(
      [@subject.scope, route].join,
      opts,
      @subject
    )

    @subject.add_endpoint(ept)
    @subject.call_with_subject(Proc.new, ept) if block_given?
  end

  def defaults(&block)
    raise ArgumentError unless block_given?

    @subject.call_with_subject(Proc.new, @subject.defaults_dslsub)
  end

  def error_hook(&block)
    raise ArgumentError unless block_given?

    @subject.error_hooks << block
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