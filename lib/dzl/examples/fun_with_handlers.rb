require 'dzl/examples/base'

class Dzl::Examples::FunWithHandlers < Dzl::Examples::Base
  defaults do
    content_type 'application/json'
  end

  error_hook do |e|
    Object.first_error_hook
  end

  error_hook do |e|
    Object.second_error_hook

    if e.to_s.match('explode')
      raise 'explode'
    end
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

  get '/explode' do
    handle do
      raise 'explode'
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