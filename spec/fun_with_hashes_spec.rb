require 'spec_helper'
require 'rack/test'
require 'dzl/examples/fun_with_hashes'

describe 'hash parameters' do
  include Rack::Test::Methods
  def app; Dzl::Examples::FunWithHashes; end

  context 'DSL' do
    specify 'hash parameters must have a validator, for now' do
      expect {
        class T1 < Dzl::Examples::Base
          get '/foo' do
            required :bar do
              type Hash
            end
          end
        end
      }.to raise_exception(ArgumentError)

      expect {
        class T1 < Dzl::Examples::Base
          get '/foo' do
            required :bar do
              type Hash, validator: HashValidator.new
            end
          end
        end
      }.to_not raise_exception(ArgumentError)
    end
  end

  context 'validate' do
    specify 'JSON post bodies' do
      header 'Content-Type', 'application/json'
      valid_body = {
        foo: {
          str: 'hello',
          ary: [7, 3],
          nest: {
            int: 5
          }
        }
      }

      invalid_body = {
        foo: {
          str: 'hello',
          ary: [7, 6, 5],
          nest: {
            int: 7
          }
        }
      }

      missing_foo = {
        baz: {
          str: 'hello',
          ary: [7, 5],
          nest: {
            int: 5
          }
        }
      }

      post('/h', valid_body.to_json).status.should == 200
      post('/h', missing_foo.to_json).status.should == 404
      post('/h', invalid_body.to_json).status.should == 404
    end
  end
end