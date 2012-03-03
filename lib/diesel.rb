require 'active_support/core_ext'
require 'diesel/version'
require 'diesel/logger'
require 'diesel/value_or_error'
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


  # TODO this won't work for apps requiring us as a gem
  def self.root
    @@root ||= File.expand_path('../../', __FILE__)
  end

  def self.env
    'development'
  end

  def self.development?
    true
  end
end

