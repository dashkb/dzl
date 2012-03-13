require 'spec_helper'
require 'rack/test'
require 'distil/examples/fun_with_hooks'

describe 'FunWithHooks' do
  include Rack::Test::Methods
  def app; Distil::Examples::FunWithHooks; end

  describe '/pre' do
    it 'only transforms :foo == 1' do
      get('/pre', {foo: 2}) do |response|
        response.status.should == 404
        JSON.parse(response.body)['errors']['/pre']['foo'].should == 'value_validation_failed'
      end

      get('/pre', {foo: 6}) do |response|
        response.status.should == 200
      end

      get('/pre', {foo: 1}) do |response|
        response.status.should == 200
        JSON.parse(response.body)['params']['foo'].should == 4
      end
    end
  end

  describe '/post' do
    it 'can operate on parameters' do
      get('/post?foo=4') do |response|
        JSON.parse(response.body)['params']['foo'].should == 8
      end
    end
  end

  describe '/multiply' do
    it 'can be used to fudge new parameters' do
      get('/multiply?x=3&y=7') do |response|
        JSON.parse(response.body)['params']['z'].should == 21
      end
    end

    it 'runs multiple after_validate hooks in order' do
      get('/omg_math?x=2&y=4&z=8&prefix=hello') do |response|
        response.status.should == 200
        params = JSON.parse(response.body)['params']
        params['multiply_then_add'].should == 16
        params['speak'].should == 'hello 16'
        [params['x'], params['y'], params['z']].should == [2, 4, 8]
      end
    end
  end

  describe 'after validate hooks' do
    it 'are good places to raise Distil::BadRequest' do
      get('/vomit') do |response|
        response.status.should == 400
        JSON.parse(response.body)['errors'].should == "This isn't quite what I was expecting"
      end
    end
  end
end