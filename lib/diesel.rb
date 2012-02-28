require 'active_support/core_ext'
require 'diesel/version'
require 'diesel/dsl'
require 'diesel/router'
require 'diesel/rack_interface'

module Diesel
  def self.included(base)
    base.extend(DSL)
    base.extend(RackInterface)
  end
end

require 'diesel/examples/app'
