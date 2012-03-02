require 'active_support/core_ext'
require 'diesel/value_or_error'
require 'diesel/version'
require 'diesel/dsl'
require 'diesel/router'
require 'diesel/response_context'
require 'diesel/rack_interface'

module Diesel
  class NYI < StandardError; end

  def self.included(base)
    base.extend(DSL)
    base.extend(RackInterface)
  end
end

