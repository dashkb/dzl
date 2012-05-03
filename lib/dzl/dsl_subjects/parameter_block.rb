require 'dzl/dsl_proxies/parameter_block'

class Dzl::DSLSubjects::ParameterBlock < Dzl::DSLSubject
  attr_accessor :params
  attr_reader :router

  def initialize(name, opts, router)
    @name   = name
    @opts   = opts
    @router = router
    @params = {}
    @dsl_proxy = Dzl::DSLProxies::ParameterBlock.new(self)
  end

  def validate(parandidates, request)
    errors = @params.each_with_object({}) do |pary, errors|
      pname, param = pary
      parandidate_key = param.opts[:header] ? :headers : :params
      parandidate = parandidates[parandidate_key][pname]

      if param.opts[:type] == Hash
        param = if parandidate.nil? && param.opts[:required]
          Dzl::ValueOrError.new(e: param.opts[:header] ? :missing_required_header : :missing_required_param)
        elsif parandidate.nil?
          # TODO HashValidator with default values
          Dzl::ValueOrError.new(v: param.default_value)
        else
          unless parandidate.is_a?(Hash)
            if param.opts[:format] == :json
              parandidate = JSON.parse(parandidate).recursively_symbolize_keys! rescue nil
            end
          end

          if parandidate.nil?
            Dzl::ValueOrError.new(e: :type_conversion_failed)
          elsif param.valid?(parandidate)
            Dzl::ValueOrError.new(v: parandidate)
          else
            Dzl::ValueOrError.new(e: :hash_validation_failed)
          end
        end
      else
        param = param.validate(parandidate, {
          preformatted: request.preformatted_keys.include?(pname)
        })
      end

      if param.error?
        errors[pname] = param.error
      else
        parandidates[parandidate_key][pname] = param.value unless param.value == :__no_value__
      end
    end || {}

    # Check for extra request params we are not expecting
    parandidates[:params].each do |pname, value|
      unless @params.keys.include?(pname)
        parandidates[:params].delete(pname)
        errors[pname] = :unknown_param
      end
    end

    if @opts[:protection]
      protection_errors = @opts[:protection].collect do |protection|
        protection.allow?(parandidates, request)
      end.select { |result| result.error? }

      if protection_errors.empty? && errors.empty?
        Dzl::ValueOrError.new(v: parandidates)
      elsif !protection_errors.empty?
        protection_errors.first
      else
        Dzl::ValueOrError.new(e: errors)
      end
    elsif !errors.empty?
      Dzl::ValueOrError.new(e: errors)
    else
      Dzl::ValueOrError.new(v: parandidates)
    end
  end

  def to_s
    "pblock:#{name}"
  end

  def as_json(opts=nil)
    {
      opts: @opts,
      params: @params
    }
  end
end