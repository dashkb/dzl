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

    required :z do
      type String
    end

    handle do
      response['Content-Type'] = 'application/json'
      {
        endpoint: endpoint,
        params: params
      }.to_json
    end
  end

  endpoint '/foo/:id' do
    required :id do
      type Numeric
    end

    handle {'id as numeric'}
  end
end