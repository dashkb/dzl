require 'spec_helper'
require 'rack/test'
require 'diesel/examples/fun_with_requests'

describe 'endpoint request method' do
  include Rack::Test::Methods
  def app; Diesel::Examples::FunWithRequests; end

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
end