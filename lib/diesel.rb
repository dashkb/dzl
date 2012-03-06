require 'active_support/core_ext'
require 'diesel/version'
require 'diesel/logger'
require 'diesel/errors'
require 'diesel/value_or_error'
require 'diesel/response_context'
require 'diesel/rack_interface'

require 'diesel/dsl_subject'

require 'diesel/dsl_subjects/router'
require 'diesel/dsl_subjects/parameter'
require 'diesel/dsl_subjects/protection'
require 'diesel/dsl_subjects/parameter_block'
require 'diesel/dsl_subjects/endpoint'

module Diesel
  class NYI < StandardError; end

  def self.included(base)
    base.extend(RackInterface)

    class << base
      alias_method :orig_mm, :method_missing
      alias_method :orig_respond_to?, :respond_to?

      def __router
        @__router ||= Diesel::DSLSubjects::Router.new
      end

      def respond_to?(m)
        orig_respond_to?(m) || (__router && __router.dsl_proxy.respond_to?(m))
      end

      def method_missing(m, *args, &block)
        if __router.dsl_proxy.respond_to?(m)
          __router.dsl_proxy.send(m, *args, &block)
        else
          orig_mm(m, *args, &block)
        end
      end
    end
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

