module Diesel::Examples; end

class Diesel::Examples::FunWithParams
  include Diesel

  endpoint '/foo' do
    required :foo do
      type Array
      disallowed_values %w{zilch zip nada}
    end
  end

  endpoint '/foo/:bar' do
    required :bar do
      type Time
    end
  end

  endpoint '/foo/:bar'
end