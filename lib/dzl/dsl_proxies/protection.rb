class Dzl::DSLProxies::Protection < Dzl::DSLProxy
  def http_basic(opts)
    raise ArgumentError unless [:username, :password].all? {|k| opts[k].present?}
    @subject.opts[:http_basic] = opts
  end
  def api_key(opts)
    raise ArgumentError unless opts[:header].present?
    raise ArgumentError unless [:validate_with, :valid_keys].one? {|k| opts[k].present?}
    @subject.opts[:api_key] = opts
  end
end
