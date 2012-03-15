class Dzl::Reloader
  SKIP = [
    /\/config\//,
    /\/deploy\//,
    /\/scripts\//
  ]

  def initialize(app)
    @app = app
    @files = Dir["#{app.root}/**/*.rb"]
    @last_reload = Time.now
  end

  def reload_if_updated
    reload! if updated?
  end

  def reload!
    @app.__wipe

    @files.each do |file|
      begin
        load(file) if SKIP.none? {|re| file.match(re)} && $LOADED_FEATURES.include?(file)
      rescue LoadError, SyntaxError, SystemStackError => e
        @app.logger.error(e)
        @app.logger.error(e.backtrace)
        @app.logger.error "While loading file #{file}"
      end
    end

    @last_reload = Time.now
  end

  private
  def updated?
    # If it hasn't been two seconds, don't reload.
    updated_at > (@last_reload + 2.seconds)
  end

  def files_and_mtimes(rb_files)
    rb_files.each_with_object({}) do |file, out|
      out[file] = File.mtime(file)
    end
  end

  def updated_at
    @files.collect {|f| File.mtime(f)}.max
  end
end

