module Diesel::Examples; end

class Diesel::Examples::App
  include Diesel

  endpoint '/favicon.ico' do
    handle do
      'favicon... who cares'
    end
  end

  endpoint '/foo/:name' do
    required :name

    handle do
      "asked for foo #{params}"
    end
  end
end