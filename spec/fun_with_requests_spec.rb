require 'spec_helper'
require 'rack/test'
require 'dzl/examples/fun_with_requests'

describe 'endpoint request method' do
  include Rack::Test::Methods
  def app; Dzl::Examples::FunWithRequests; end

  it 'defaults to GET' do
    get('/foo') do |response|
      response.status.should == 200
      response.body.should == 'get'
    end
  end

  it 'allows specification through endpoint options' do
    post('/post_op') do |response|
      response.status.should == 200
      response.body.should == 'post'
    end

    get('/post_op') do |response|
      response.status.should == 404
      JSON.parse(response.body)['errors']['/post_op'].should == 'request_method_not_supported'
    end
  end

  it 'allows specification of multiple request methods' do
    post('/multi_op') do |response|
      response.status.should == 200
      response.body.should == 'post'
    end

    put('/multi_op') do |response|
      response.status.should == 200
      response.body.should == 'put'
    end

    get('/multi_op') do |response|
      response.status.should == 404
    end
  end

  describe 'aliases' do
    it 'work as expected' do
      get('/get_only') do |response|
        response.status.should == 200
      end

      post('/get_only') do |response|
        response.status.should == 404
      end

      delete('/delete_only') do |response|
        response.status.should == 200
      end
    end

    it 'allow multiple methods the regular way' do
      get('/get_and_post') do |response|
        response.status.should == 200
      end

      post('/get_and_post') do |response|
        response.status.should == 200
      end
    end
  end

  describe 'validating headers' do
    it 'rejects invalid values' do
      get('/validated_header', {}, {'HTTP_KEY' => 'hell'}) do |response|
        response.status.should == 404
      end
    end

    it 'accepts valid values' do
      get('/validated_header', {}, {'HTTP_KEY' => 'hello'}) do |response|
        response.status.should == 200
      end
    end
  end

  describe 'ambiguous routes' do
    it 'should respond with the right endpoint' do
      get('/ambiguous', {foo: 'foo'}) do |response|
        response.status.should == 200
        response.body.should == 'foo'
      end

      get('/ambiguous', {bar: 'bar'}) do |response|
        response.status.should == 200
        response.body.should == 'bar'
      end

      get('/ambiguous', {baz: 'baz'}) do |response|
        response.status.should == 404
      end
    end
  end
end