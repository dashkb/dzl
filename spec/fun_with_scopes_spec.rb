require 'spec_helper'
require 'rack/test'
require 'dzl/examples/fun_with_scopes'

describe 'scopes' do
  include Rack::Test::Methods
  def app; Dzl::Examples::FunWithScopes; end

  it 'make routes available under the specified path' do
    get('/foo/bar') { |r| r.status.should == 200 }
    get('/foo/foo') { |r| r.status.should == 404 }
    get('/bar/foo') { |r| r.status.should == 200 }
    get('/zoom')    { |r| r.status.should == 200 }
  end

  it 'can be nested' do
    ['/nest/this/first', '/nest/and', '/nest/that/second'].each do |route|
      get(route) { |r| r.status.should == 200 }
    end

    ['/nest/that/first', '/nest/this/and', '/nest/this/and/that', '/nest/that/first'].each do |route|
      get(route) { |r| r.status.should == 404 }
    end
  end

  it 'must start with a slash' do
    expect {
      class Dzl::Examples::FunWithScopes
        scope 'not-a-slash' do
          two = 1 + 1
        end
      end
    }.to raise_error(ArgumentError)
  end

  it "don't brake pblocks" do
    # pblocks aren't scoped
    expect {
      class Dzl::Examples::FunWithScopes
        scope '/whatever' do
          pblock :foo do
            required :foo
          end

          get '/foo' do
            import_pblock :foo
          end
        end

        scope '/another_scope' do
          get '/foo' do
            import_pblock :foo
          end
        end
      end
    }.to_not raise_error

    get('/another_scope/foo') do |response|
      response.status.should == 404
      JSON.parse(response.body)['errors']['/another_scope/foo'].should == {
        'foo' => 'missing_required_param'
      }
    end
  end
end