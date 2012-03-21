require 'dzl/dsl_proxies/scope'

class Dzl::DSLSubjects::Scope < Dzl::DSLSubject
  def initialize(path)
    @path = path
  end
end