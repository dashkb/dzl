class ActiveSupport::BufferedLogger
  def self.timestamp
    DateTime.now.strftime("[%Y-%m-%d %H:%M%S] - ")
  end

  alias_method :orig_add, :add
  def add(severity, message = nil, progname = nil, &block)
    message = "#{ActiveSupport::BufferedLogger.timestamp}#{message}"
    orig_add(severity, message, progname, &block)
  end
end

module Diesel
  class Logger
    def initialize
      @loggers = {
        default: create_logger # log/[environment].log
      }
    end

    # Get the standard logger methods defined
    %w{debug info warn error fatal}.each do |severity|
      severity = severity.to_sym
      define_method(severity) do |msg|
        log(severity, msg)
      end
    end

    ############
    # Receives all the default log methods on Diesel.logger
    # and forwards to the default logger
    ############
    def log(severity, msg)
      @loggers[:default].send(severity, msg)
    end

    ############
    # The idea here is that you can call
    # Diesel.logger.tidy.debug("Something")
    # and we'll write your log message to tidy.environment.log
    ############
    def method_missing(method)
      @loggers[method] ||= create_logger(method.to_s)
    end

    private
    def create_logger(name = nil)
      logfile = name ? "#{name}.#{Diesel.env}.log" : "#{Diesel.env}.log"
      ActiveSupport::BufferedLogger.new(
        File.join(Diesel.root, 'log', logfile),
        %w{ staging production }.include?(Diesel.env) ? ::Logger::INFO : ::Logger::DEBUG
      )
    end
  end

  def self.logger
    @@logger ||= Logger.new
  end
end