class Diesel::DSLProxies::ParameterBlock < Diesel::DSLProxy
  def parameter(*names)
    opts = names.last.is_a?(Hash) ? names.pop : {required: false}

    names.each do |name|
      if @subject.params[name]
        # Don't clobber params we already know about
        @subject.params[name].overwrite_opts(opts)
      else
        @subject.params[name] = Diesel::DSLSubjects::Parameter.new(name, opts)
      end

      @subject.router.call_with_subject(Proc.new, @subject.params[name]) if block_given?
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
      @subject.params.delete(name)
    end
  end

  def import_pblock(*pblocks)
    pblocks.each do |pblock|
      @subject.router[:pblocks][pblock].params.each do |name, param|
        @subject.params[name] = param.dup
      end
    end
  end
end