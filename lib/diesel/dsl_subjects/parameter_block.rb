require 'diesel/dsl_proxies/parameter_block'

class Diesel::DSLSubjects::ParameterBlock < Diesel::DSLSubject
  attr_accessor :params

  def initialize(name, opts, router)
    @name   = name
    @opts   = opts
    @router = router
    @params = {}
    @dsl_proxy = Diesel::DSLProxies::ParameterBlock.new(self)
  end

  def validate(parandidates)
    errors = @params.each_with_object({}) do |pary, errors|
      pname, param = pary
      parandidate_key = param.opts[:header] ? :headers : :params

      # verror = value or error.
      verror = @params[pname].validation_error(parandidates[parandidate_key][pname])
      unless verror.valid?
        errors[pname] = verror.error
      else
        parandidates[parandidate_key][pname] = verror.value unless verror.value.nil?
      end
    end || {}

    # Check for extra request params we are not expecting
    parandidates[:params].each do |pname, value|
      unless @params.keys.include?(pname)
        parandidates[:params].delete(pname)
        errors[pname] = :unknown_param
      end
    end

    errors
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