require 'diesel/version'
require 'diesel/dsl'
require 'diesel/parameter'
require 'diesel/parameter_block'
require 'diesel/endpoint'
require 'active_support/core_ext'


module Diesel
  def self.included(base)
    base.extend(DSL)
  end
end

require 'diesel/app' # example app

$r = Diesel::App.router