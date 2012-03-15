class Dzl::DSLProxies::Defaults < Dzl::DSLProxy
  def method_missing(m, *args, &block)
    raise ArgumentError if args.size != 1
    @subject.set_default(m, args[0])
  end

  def respond_to?(m)
    true
  end
end