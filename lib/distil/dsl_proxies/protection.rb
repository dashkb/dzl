class Distil::DSLProxies::Protection < Distil::DSLProxy
  def http_basic(opts)
    raise ArgumentError unless [:username, :password].all? {|k| opts[k].present?}
    @subject.opts[:http_basic] = opts
  end
end