require 'distil/examples/base'

class Distil::Examples::FunWithHandlers < Distil::Examples::Base
  defaults do
    content_type 'application/json'
  end

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

  get '/raise' do
    handle do
      raise 'omg'
    end
  end
end