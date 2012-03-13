module Distil::Examples
  class Base
    def self.root
      @@root ||= File.expand_path('../../../../', __FILE__)
    end

    include Distil
  end
end