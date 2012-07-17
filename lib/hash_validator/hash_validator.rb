require 'mzl'

class HashValidator
  attr_reader :dsl_proxy, :subject
  attr_accessor :default_value

  def initialize(opts = {})
    @template = {
      keys: {},
      opts: opts
    }

    @key_stack = []
    @default_value = :__no_value__
    @dsl_proxy = self # for Dzl, for now
    @subject = self # for Dzl, for now
  end

  def opts
    @template[:opts]
  end

  def overwrite_opts(opts)
    @template[:opts].merge(opts)
  end

  def clone
    copy = HashValidator.new
    copy.instance_variable_set(:@template, Marshal.load(Marshal.dump(@template)))
    copy
  end

  def valid?(hsh)
    return false unless hsh.keys.all? { |key| top[:keys].include?(key) }

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

  def top
    @key_stack.inject(@template) { |ref, key| ref[:keys][key] } || @template
  end

  def add_option(k, v)
    top[:opts][k] = v
  end

  mzl.defaults[:def][:persist] = true
  mzl.override_new

  mzl.def :key do |k, opts = {}, &block|
    opts.reverse_merge!({
      type: String
    })

    top[:keys][k] = {
      opts: opts,
      keys: {}
    }

    @key_stack.push(k)
    instance_exec(&block) if block.is_a?(Proc)
    @key_stack.pop
  end

  mzl.def :optional do |*args, &block|
    opts = args.last.is_a?(Hash) ? args.pop : {}
    args.each do |key|
      key(key, opts.merge({required: false}), &block)
    end
  end

  mzl.def :required do |*args, &block|
    opts = args.last.is_a?(Hash) ? args.pop : {}
    args.each do |key|
      key(key, opts.merge({required: true}), &block)
    end
  end

  mzl.def :type do |klass|
    raise ArgumentError unless klass.is_a?(Class)
    add_option(:type, klass)
  end

  mzl.def :allowed_values do |*ary|
    if ary.is_a?(Array) && ary[0].is_a?(Array) && ary.length == 1
      ary = ary[0]
    end

    add_option(:allowed_values, ary)
  end

  mzl.def :forbidden_values do |*ary|
    if ary.is_a?(Array) && ary[0].is_a?(Array) && ary.length == 1
      ary = ary[0]
    end

    add_option(:forbidden_values, ary)
  end

  mzl.def :default do |hsh|
    raise ArgumentError unless hsh.is_a?(Hash)
    @default_value = hsh
  end
end