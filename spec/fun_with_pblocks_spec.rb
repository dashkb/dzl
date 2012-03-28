require 'spec_helper'
require 'rack/test'
require 'dzl/examples/fun_with_pblocks'

describe Dzl::Examples::FunWithPblocks do
  def app; Dzl::Examples::FunWithPblocks; end
  include Rack::Test::Methods

  specify '/foo required :ary size == 2' do
    get('/foo?ary=one%20two').status.should == 200
    get('/foo?ary=one%20two%20three%20four').status.should == 404
  end

  specify '/bar required :ary size == 4' do
    get('/bar?ary=one%20two%20three%20four').status.should == 200
    get('/bar?ary=one%20two').status.should == 404
  end
end