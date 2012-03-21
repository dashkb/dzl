require 'dzl/examples/base'

class Dzl::Examples::FunWithScopes < Dzl::Examples::Base
  scope '/foo' do
    get '/bar'
    get '/baz'
  end

  scope '/bar' do
    get '/foo'
    get '/baz'
  end

  scope '/nest' do
    scope '/this' do
      get '/first'
    end

    get '/and'

    scope '/that' do
      get '/second'
    end
  end

  get '/zoom'
end