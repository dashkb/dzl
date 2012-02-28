require 'spec_helper'
require 'rack/test'

class EPTestApp
  include Diesel

  endpoint '/foos'
  endpoint '/foos/:name' do
    required :name do
      type String
    end

    optional :number do
      type Numeric
    end
  end

  endpoint '/hello' do
    handle {'world'}
  end

  endpoint '/can_access_request_object' do
    handle { request.is_a?(Rack::Request) ? 'OK' : 'FAIL' }
  end

  endpoint '/can_access_response_object' do
    handle { response.is_a?(Rack::Response) ? 'OK' : 'FAIL' }
  end

  endpoint '/can_modify_response_object' do
    handle do
      response['Content-Type'] = 'foo'
      response.write('FOO')
    end
  end

  endpoint '/can_set_code' do
    handle { response.status = 123 }
  end
end


describe Diesel::DSL::Endpoint do
  include Rack::Test::Methods
  def app
    @app ||= EPTestApp
  end

  describe '#respond_to_request?' do
    it 'is true for a direct string match' do
      EPTestApp._router.routes.has_key?('/foos').should == true
      ep = EPTestApp._router.routes['/foos']

      yay  = Rack::Request.new(Rack::MockRequest.env_for('/foos'))
      bad = Rack::Request.new(Rack::MockRequest.env_for('/food'))
      sad = Rack::Request.new(Rack::MockRequest.env_for('/foos/99'))

      ep.respond_to_request?(yay).should == true
      ep.respond_to_request?(bad).should == false
      ep.respond_to_request?(sad).should == false
    end

    it 'is true for a params-in-path simple string match' do
      EPTestApp._router.routes.has_key?('/foos/:name').should == true
      ep = EPTestApp._router.routes['/foos/:name']
      ep.pblock.params.has_key?(:name).should == true

      request = Rack::Request.new(Rack::MockRequest.env_for('/foos/mine'))

      ep.respond_to_request?(request).should == true
    end

    it 'is false for a params-in-path match with incorrect type' do
      ep = EPTestApp._router.routes['/foos/:name']
      ep.pblock.params.has_key?(:name).should == true

      request = Rack::Request.new(Rack::MockRequest.env_for('/foos/12'))

      ep.respond_to_request?(request).should == false
    end
  end

  describe 'the handler block' do
    it 'should respond to requests' do
      get '/hello'
      last_response.body.should == 'world'
    end

    it 'can respond with an arbitrary code' do
      get '/can_set_code'
      last_response.status.should == 123
    end

    it 'should have access to the request object' do
      get '/can_access_request_object'
      last_response.body.should == 'OK'
    end

    it 'should have access to the response object' do
      get '/can_access_response_object'
      last_response.body.should == 'OK'
    end

    it 'can modify the response object' do
      get '/can_modify_response_object'
      last_response.content_type.should == 'foo'
      last_response.body.should == 'FOO'
    end
  end
end