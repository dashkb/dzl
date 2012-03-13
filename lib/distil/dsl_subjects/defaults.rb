require 'distil/dsl_proxies/defaults'

class Distil::DSLSubjects::Defaults < Distil::DSLSubject
  def initialize(router)
    @dsl_proxy = Distil::DSLProxies::Defaults.new(self)
    @router = router
  end

  def set_default(key, val)
    @router.defaults[key] = val
  end
end