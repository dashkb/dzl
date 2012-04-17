class Dzl::Error < StandardError
  attr_reader :data, :status

  def initialize(data = {})
    @data = data
    @status = 500
  end

  def [](key)
    @data[key]
  end

  def to_json
    {
      status: @status,
      error_class: self.class.to_s,
      errors: @data,
      trace: self.backtrace
    }.to_json
  end
end

class Dzl::RequestError < Dzl::Error; end

class Dzl::NotFound < Dzl::RequestError
  def initialize(data = {})
    super(data)
    @status = 404
  end
end

class Dzl::BadRequest < Dzl::RequestError
  def initialize(data = {})
    super(data)
    @status = 400
  end
end

class Dzl::RetryBlockPlease < Dzl::Error; end
class Dzl::Deprecated < Dzl::Error; end
