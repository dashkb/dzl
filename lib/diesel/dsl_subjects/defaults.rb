require 'diesel/dsl_proxies/defaults'

class Diesel::DSLSubjects::Defaults < Diesel::DSLSubject
  def initialize(router)
    @dsl_proxy = Diesel::DSLProxies::Defaults.new(self)
    @router = router
  end

  def set_default(key, val)
    @router.defaults[key] = val
  end
end