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

      param = @params[pname].validate(parandidates[parandidate_key][pname], {
        preformatted: request.preformatted_keys.include?(pname)
      })

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

    if !errors.empty?
      Dzl::ValueOrError.new(e: errors)
    elsif @opts[:protection]
      protection_errors = @opts[:protection].collect do |protection|
        protection.allow?(parandidates, request)
      end.select { |result| result.error? }

      if protection_errors.empty?
        Dzl::ValueOrError.new(v: parandidates)
      else
        protection_errors[0]
      end
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