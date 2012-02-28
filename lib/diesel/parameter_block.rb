require 'diesel/parameter_block_dsl'

class Diesel::ParameterBlock
  include Diesel::ParameterBlockDSL
  attr_accessor :name, :opts, :params

  def initialize(name, opts, router)
    @name   = name
    @opts   = opts
    @router = router
    @params = {}
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