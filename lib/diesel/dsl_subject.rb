require 'diesel/dsl_proxy'

class Diesel::DSLSubject
  attr_reader :name, :opts, :router

  def initialize
    @opts = {}
  end

  def dsl_proxy
    @dsl_proxy || raise("You must set @dsl_proxy in your DSLSubject subclass")
  end
end

module Diesel::DSLSubjects; end