require 'spec_helper'
require 'rack/test'
require 'dzl/examples/scribe'

describe Dzl::Examples::Scribe do
  def app; Dzl::Examples::Scribe; end
  include Rack::Test::Methods

  specify 'default array separator is |' do
    Dzl::Examples::Scribe.__router.defaults[:array_separator].should == '|'

    get('/series', {actions: 'this|that|these'}) do |response|
      JSON.parse(response.body)['params']['actions'].should == ['this', 'that', 'these']
    end
  end
end