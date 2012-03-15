require 'active_support/core_ext'
require 'dzl/version'
require 'dzl/logger'
require 'dzl/errors'
require 'dzl/value_or_error'
require 'dzl/response_context'
require 'dzl/rack_interface'
require 'dzl/doc/router_doc'
require 'dzl/doc/endpoint_doc'

require 'dzl/dsl_subject'

require 'dzl/dsl_subjects/router'
require 'dzl/dsl_subjects/parameter'
require 'dzl/dsl_subjects/protection'
require 'dzl/dsl_subjects/parameter_block'
require 'dzl/dsl_subjects/endpoint'

module Dzl
  class NYI < StandardError; end

  def self.included(base)
    unless base.respond_to?(:root)
      raise ArgumentError.new(
        "Please define #{base}.root to return the path to your app"
      )
    end

    base.extend(RackInterface)

    class << base
      alias_method :orig_mm, :method_missing
      alias_method :orig_respond_to?, :respond_to?

      def __router
        @__router ||= Dzl::DSLSubjects::Router.new(self)
      end

      def __logger
        @__logger ||= begin
          if self.orig_respond_to?(:logger) && self.logger.is_a?(ActiveSupport::BufferedLogger)
            self.logger
          else
            Dzl::Logger.new(self.root)
          end
        end
      end

      def respond_to?(m)
        orig_respond_to?(m) || (__router && __router.dsl_proxy.respond_to?(m))
      end

      def method_missing(m, *args, &block)
        if __router.dsl_proxy.respond_to?(m)
          __router.dsl_proxy.send(m, *args, &block)
        elsif m == :logger
          __logger
        else
          orig_mm(m, *args, &block)
        end
      end

      def to_docs
        app_name = self.name.split('::').last
        
        `mkdir -p ./dzl_docs/#{app_name}/`

        home = File.new("./dzl_docs/#{app_name}/Home.md", "w")
        home.write(__router.to_md(app_name))
        home.close

        __router.endpoints.each do |endpoint|
          endpoint_page = File.new("./dzl_docs/#{app_name}/#{endpoint.doc_file_name}.md", "w")
          endpoint_page.write(endpoint.to_md)
          endpoint_page.close
        end
      end
    end
  end

  def self.env
    ENV['RACK_ENV']
  end

  [:development?, :production?, :staging?, :test?].each do |m|
    define_singleton_method(m) do
      env == m.to_s[0..-2]
    end
  end

  def self.development?
    true
  end
end

Diesel = Dzl
