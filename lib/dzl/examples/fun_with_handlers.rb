require 'dzl/examples/base'

class Dzl::Examples::FunWithHandlers < Dzl::Examples::Base
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

  get '/validation_error' do
    handle do
      raise Dzl::ValidationError.new(
        any: 'hash',
        i: 'want'
      )
    end
  end
end