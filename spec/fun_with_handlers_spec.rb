require 'spec_helper'
require 'rack/test'
require 'dzl/examples/fun_with_handlers'

describe 'handlers' do
  include Rack::Test::Methods
  def app; Dzl::Examples::FunWithHandlers; end

  it 'have access to parameters and headers' do
    get '/say_bar?baz=no&bam=nope&bar=Hello%2C%20world' do |response|
      response.status.should == 200
      response.body.should == 'Hello, world'
    end

    get('/say_bar_and_api_key', {bar: 'Hello, world'}, {'HTTP_ApI-keY' => 'open sesame'}) do |response|
      response.status.should == 200
      response['Content-Type'].should == 'application/json'
      JSON.parse(response.body).should == {
        'bar' => 'Hello, world',
        'api_key' => 'open sesame'
      }
    end

    get('/say_bar_and_api_key', {bar: 'whatever'}) do |response|
      response.status.should == 404
      JSON.parse(response.body)['errors']['/say_bar_and_api_key'].should == {
        'api_key' => 'missing_required_header'
      }
    end
  end

  it 'can raise exceptions without exploding everything' do
    get '/raise' do |response|
      response.status.should == 500
    end
  end
end