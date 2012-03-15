require 'dzl/dsl_proxy'

class Dzl::DSLSubject
  attr_reader :name, :opts, :router

  def initialize
    @opts = {}
  end

  def dsl_proxy
    @dsl_proxy || raise("You must set @dsl_proxy in your DSLSubject subclass")
  end
end

module Dzl::DSLSubjects; end