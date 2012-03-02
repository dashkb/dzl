require 'spec_helper'
require 'rack/test'
require 'diesel/examples/fun_with_params'

describe Diesel::Examples::FunWithParams do
  include Rack::Test::Methods

  def app; Diesel::Examples::FunWithParams; end

  describe '/foo' do
    describe "understands disallowed values" do
      it "for arrays" do
        all_good = ['ok', 'sweet', 'awesome'].join(' ')
        one_bad = ['zip'].join(' ')
        all_bad = ['zip', 'zilch', 'nada'].join(' ')
        mixed = ['ok', 'sweet', 'nada', 'nice'].join(' ')

        get('/foo', {foo: all_good}) do |response|
          response.status.should == 200
        end

        get('/foo', {foo: one_bad}) do |response|
          response.status.should == 404
          JSON.parse(response.body)['errors']['/foo'].should == {
            'foo' => 'disallowed_values_failed'
          }
        end

        get('/foo', {foo: all_bad}) do |response|
          response.status.should == 404
          JSON.parse(response.body)['errors']['/foo'].should == {
            'foo' => 'disallowed_values_failed'
          }
        end

        get('/foo', {foo: mixed}) do |response|
          response.status.should == 404
          JSON.parse(response.body)['errors']['/foo'].should == {
            'foo' => 'disallowed_values_failed'
          }
        end
      end
    end
  end
end