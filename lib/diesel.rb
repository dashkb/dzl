require 'diesel/version'
require 'diesel/dsl'
require 'active_support/core_ext'

module Diesel
  def self.included(base)
    base.extend(DSL)
  end
end
