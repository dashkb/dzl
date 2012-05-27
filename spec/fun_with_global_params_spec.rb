require 'spec_helper'
require 'rack/test'
require 'dzl/examples/fun_with_global_params'

describe Dzl::Examples::FunWithGlobalParams do
  include Rack::Test::Methods

  def app; Dzl::Examples::FunWithGlobalParams; end

  describe '/globally_protected' do
    before(:each) {header 'Content-Type', 'application/json'}
    let(:post_body) {{'number' => 23}.to_json}
    let(:valid_key) {{'HTTP_X_API_KEY' => 'valid-key'}}

    it 'should 401 if no api key provided' do
      post '/globally_protected'
      last_response.status.should == 401
    end

    it 'should 401 if invalid api key provided' do
      post '/globally_protected', {}, {"HTTP_X_API_KEY" => 'invalid-key'}
      last_response.status.should == 401
    end

    it 'should accept valid api key' do
      post '/globally_protected', post_body, valid_key
      last_response.status.should == 200
    end

    it 'should reject invalid required parameter' do
      invalid_body = {'number' => 'string'}.to_json
      post('/globally_protected', invalid_body, valid_key) do |response|
        response.status.should == 404
        JSON.parse(response.body)['errors']['/globally_protected'].should == {
          'number' => 'type_conversion_error'
        }
      end
    end
  end
end
