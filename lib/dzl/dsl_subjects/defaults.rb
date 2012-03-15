require 'dzl/dsl_proxies/defaults'

class Dzl::DSLSubjects::Defaults < Dzl::DSLSubject
  def initialize(router)
    @dsl_proxy = Dzl::DSLProxies::Defaults.new(self)
    @router = router
  end

  def set_default(key, val)
    @router.defaults[key] = val
  end
end