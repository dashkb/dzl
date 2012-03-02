class Diesel::ResponseContext
  module RequestHelpers
    def params
      request.params
    end

    def headers
      request.headers
    end
  end
end