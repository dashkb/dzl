module Diesel::Examples
  class Base
    def self.root
      @@root ||= File.expand_path('../../../../', __FILE__)
    end

    include Diesel
  end
end