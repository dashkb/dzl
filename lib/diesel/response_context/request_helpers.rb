class Diesel::ResponseContext
  module RequestHelpers
    def params
      request.params
    end
  end
end