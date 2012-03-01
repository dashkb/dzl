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
    @params.each_with_object({}) do |pary, errors|
      pname, param = pary

      # verror = value or error.
      verror = @params[pname].validation_error(parandidates[pname])
      unless verror.valid?
        errors[pname] = verror.error
      else
        parandidates[pname] = verror.value unless verror.value.nil?
      end
    end || {}
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