class Dzl::DSLProxies::Protection < Dzl::DSLProxy
  def http_basic(opts)
    raise ArgumentError unless [:username, :password].all? {|k| opts[k].present?}
    @subject.opts[:http_basic] = opts
  end
end