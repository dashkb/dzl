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
end


describe Diesel::DSL::Endpoint do
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
end