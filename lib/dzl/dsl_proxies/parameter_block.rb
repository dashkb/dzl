class Dzl::DSLProxies::ParameterBlock < Dzl::DSLProxy
  def parameter(*names, &block)
    opts = names.last.is_a?(Hash) ? names.pop : {required: false}

    names.each do |name|
      single_parameter(name, opts, &block)
    end
  end
  alias_method :param, :parameter

  def single_parameter(name, opts, &block)
    if @subject.params[name] && !opts[:retry]
      # Don't clobber params we already know about
      @subject.params[name].overwrite_opts(opts)
    else
      @subject.params[name] = opts[:subject] || Dzl::DSLSubjects::Parameter.new(name, opts, @subject.router)
    end

    begin
      @subject.router.call_with_subject(Proc.new, @subject.params[name]) if block_given?
    rescue Dzl::RetryBlockPlease => e
      @subject.router.__evil_subject_pop
      single_parameter(name, opts.merge(retry: true, subject: e[:subject]), &block)
    end
  end

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
      @subject.params.delete(name)
    end
  end

  def protect
    raise ArgumentError unless block_given?
    @subject.opts[:protection] ||= []
    @subject.opts[:protection] << Dzl::DSLSubjects::Protection.new

    @subject.router.call_with_subject(Proc.new, @subject.opts[:protection].last)
  end

  def import_pblock(*pblocks)
    pblocks.each do |pblock|
      next unless @subject.router.pblocks.has_key?(pblock)
      pb = @subject.router.pblocks[pblock]
      pb.params.each do |name, param|
        @subject.params[name] = param.clone
      end
      pb.opts.each do |name, opt|
        @subject.opts[name] = opt.clone
      end
    end
  end
  alias_method :import_parameters, :import_pblock
end
