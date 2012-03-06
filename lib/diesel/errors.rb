class Diesel::Error < StandardError
  attr_reader :data, :status

  def initialize(data = {})
    @data = data
    @status = 500
  end

  def to_json
    {
      status: @status,
      error_class: self.class,
      errors: @data,
      trace: self.backtrace
    }.to_json
  end
end

class Diesel::NotFound < Diesel::Error
  def initialize(data = {})
    super(data)
    @status = 404
  end
end

class Diesel::BadRequest < Diesel::Error
  def initialize(data = {})
    super(data)
    @status = 404
  end
end