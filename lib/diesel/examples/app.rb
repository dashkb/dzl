module Diesel::Examples; end

class Diesel::Examples::App
  include Diesel

  endpoint '/favicon.ico' do
    handle do
      'favicon... who cares'
    end
  end

  endpoint '/foo/:name' do
    required :name do
      type String
    end

    handle do
      "name as string"
    end
  end

  endpoint '/foo/:id' do
    required :id do
      type Numeric
    end

    handle {'id as numeric'}
  end
end