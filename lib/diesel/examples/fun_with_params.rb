module Diesel::Examples; end

class Diesel::Examples::FunWithParams
  include Diesel

  endpoint '/foo' do
    required :foo do
      type Array
      disallowed_values %w{zilch zip nada}
    end
  end
end