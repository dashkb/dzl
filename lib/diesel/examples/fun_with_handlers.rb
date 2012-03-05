module Diesel::Examples; end

class Diesel::Examples::FunWithHandlers
  include Diesel

  endpoint '/say_bar' do
    optional :foo, :bar, :baz, :bam

    handle do
      params[:bar]
    end
  end

  endpoint '/say_bar_and_api_key' do
    required :bar
    required_header :api_key

    handle do
      {
        bar: params[:bar],
        api_key: headers[:api_key]
      }.to_json
    end
  end
end