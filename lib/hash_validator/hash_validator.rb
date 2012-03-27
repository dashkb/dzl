class HashValidator
  class << self
    alias_method :orig_new, :new
    def new(*args)
      v = orig_new(*args)
      v.instance_exec(&Proc.new) if block_given?
      v
    end
  end

  def initialize
    @template = {
      keys: {}
    }

    @key_stack = []
    @dsl_proxy = DSLProxy.new(self)
  end

  def valid?(hsh)
    top[:keys].each do |k, v|
      if !hsh.has_key?(k)
        if v[:opts][:required]
          return false
        else
          next
        end
      end
      
      input = hsh[k]

      # Check type of input
      return false unless input.is_a?(v[:opts][:type])

      if input.is_a?(Hash)
        @key_stack.push(k)

        valid?(input) or begin
          @key_stack = []
          return false
        end

        @key_stack.pop
      elsif input.is_a?(Array)
        return false if v[:opts][:allowed_values].present? &&
                        !input.all? {|_input| v[:opts][:allowed_values].include?(_input)}

        return false if v[:opts][:forbidden_values].present? &&
                        input.any? {|_input| v[:opts][:forbidden_values].include?(_input)}
      else
        return false if v[:opts][:allowed_values].present? &&
                        !v[:opts][:allowed_values].include?(hsh[k])

        return false if v[:opts][:forbidden_values].present? &&
                        v[:opts][:forbidden_values].include?(hsh[k])
      end
    end

    true
  end

  def key(k, opts, &block)
    top[:keys][k] = {
      opts: opts,
      block: block,
      keys: {}
    }

    @key_stack.push(k)
    @dsl_proxy.instance_exec(&block) if block_given?
    @key_stack.pop
  end

  def top
    @key_stack.inject(@template) { |ref, key| ref[:keys][key] } || @template
  end

  def add_option(k, v)
    top[:opts][k] = v
  end

  def method_missing(m, *args, &block)
    if @dsl_proxy.respond_to?(m)
      @dsl_proxy.send(m, *args, &block)
    else
      super(m, *args, &block)
    end
  end

  class DSLProxy
    def initialize(subject)
      @subject = subject
    end

    def key(k, opts = {}, &block)
      opts.reverse_merge!({
        type: String
      })

      @subject.key(k, opts, &block)
    end

    def optional(k, opts = {}, &block)
      key(k, opts.merge({required: false}), &block)
    end

    def required(k, opts = {}, &block)
      key(k, opts.merge({required: true}), &block)
    end

    def type(klass)
      raise ArgumentError unless klass.is_a?(Class)
      @subject.add_option(:type, klass)
    end

    def allowed_values(ary)
      @subject.add_option(:allowed_values, ary)
    end

    def forbidden_values(ary)
      @subject.add_option(:forbidden_values, ary)
    end
  end
end