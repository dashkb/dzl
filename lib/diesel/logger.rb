class ActiveSupport::BufferedLogger
  def self.timestamp
    DateTime.now.strftime("[%Y-%m-%d %H:%M:%S] - ")
  end

  alias_method :orig_add, :add
  def add(severity, message = nil, progname = nil, &block)
    message = "#{ActiveSupport::BufferedLogger.timestamp}#{message}"
    orig_add(severity, message, progname, &block)
  end
end

module Diesel
  class Logger
    LOG_METHODS = [:debug, :info, :warn, :error, :fatal]
    def initialize(app_root)
      @app_root = app_root
      @loggers = {
        default: create_logger # log/[environment].log
      }
    end

    # Get the standard logger methods defined
    LOG_METHODS.each do |severity|
      define_method(severity) do |msg|
        log(severity, msg)
      end
    end

    ############
    # Receives all the default log methods on AppClass.logger
    # and forwards to the default logger
    ############
    def log(severity, msg)
      @loggers[:default].send(severity, msg)
    end

    ############
    # The idea here is that you can call
    # AppClass.logger.tidy.debug("Something")
    # and we'll write your log message to tidy.environment.log
    ############
    alias_method :orig_mm, :method_missing
    def method_missing(m, *args, &block)
      puts "mm in logger for #{m} #{m.class}"
      return orig_mm(m, *args, &block) unless LOG_METHODS.include?(m)
      @loggers[m] ||= create_logger(m.to_s)
    end

    alias_method :orig_respond_to?, :respond_to?
    def respond_to?(m)
      puts "chekcing logger for #{method}"
      orig_respond_to?(m) || LOG_METHODS.include?(m)
    end

    private
    def create_logger(name = nil)
      logfile = name ? "#{name}.#{Diesel.env}.log" : "#{Diesel.env}.log"
      ActiveSupport::BufferedLogger.new(
        File.join(@app_root, 'log', logfile),
        %w{ staging production }.include?(Diesel.env) ? ::Logger::INFO : ::Logger::DEBUG
      )
    end
  end

  def self.logger
    @@logger ||= Logger.new
  end
end