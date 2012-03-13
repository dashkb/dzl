require 'distil/dsl_proxy'

class Distil::DSLSubject
  attr_reader :name, :opts, :router

  def initialize
    @opts = {}
  end

  def dsl_proxy
    @dsl_proxy || raise("You must set @dsl_proxy in your DSLSubject subclass")
  end
end

module Distil::DSLSubjects; end