require 'spec_helper'
require 'rack/test'
require 'dzl/examples/multi_file/first'
require 'dzl/examples/multi_file/second'

describe 'multi file apps' do
  include Rack::Test::Methods
  def app; Dzl::Examples::MultiFile::App; end

  specify 'apps can be declared in multiple files' do
    get('/one').body.should == 'one'
    get('/two').body.should == 'two'
  end

  specify 'pblock importing still works' do
    get('/import') do |response|
      response.status.should == 404
      JSON.parse(response.body)['errors']['/import']['foo'].should == 'missing_required_param'
    end
  end
end