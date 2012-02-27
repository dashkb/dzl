class Diesel::DSL::Endpoint
  attr_reader :pblock

  def initialize(name, opts, router)
    @name   = name
    @opts   = opts
    @router = router
    @pblock = Diesel::DSL::ParameterBlock.new(:anonymous, {}, @router)
  end

  def to_s
    "endpoint:#{@name}"
  end
end