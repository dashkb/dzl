require 'spec_helper'
require 'rack/test'
require 'dzl/examples/fun_with_hashes'

describe 'hash parameters' do
  include Rack::Test::Methods
  def app; Dzl::Examples::FunWithHashes; end

  context 'DSL' do
    specify 'DEPRECATED: hash parameters must have a validator, for now' do
      expect {
        class T1 < Dzl::Examples::Base
          get '/foo' do
            required :bar do
              type Hash
            end
          end
        end
      }.to_not raise_exception(ArgumentError)

      expect {
        class T1 < Dzl::Examples::Base
          get '/foo' do
            required :bar do
              type Hash, validator: HashValidator.new
            end
          end
        end
      }.to raise_exception(Dzl::Deprecated)
    end

    specify 'hash parameters retry their blocks against a hash validator' do
      HashValidator.any_instance.should_receive(:key).with(:key, {required: true, type: String})
      class T1 < Dzl::Examples::Base
        get '/foo' do
          required :bar do
            type Hash
            required(:key) do
              type Array
            end
          end
        end
      end
    end

    specify 'hash validator is built properly for required params' do
      class T1 < Dzl::Examples::Base
        get '/foo' do
          required :bar do
            type Hash
            self.subject.opts.should == {type: Hash, required: true, format: :json}

            required(:key) do
              self.subject.should_receive(:add_option).with(:type, Array)
              type Array
            end
          end
        end
      end
    end

    specify 'nested hashes do not retry their blocks against a new hash validator' do
      class T1 < Dzl::Examples::Base
        get '/foo' do
          required :bar do
            type Hash
            HashValidator.any_instance.should_receive(:key)
            required(:nested) do
              HashValidator.any_instance.should_not_receive(:new)
              HashValidator.any_instance.should_receive(:add_option).with(:type, Hash)
              type Hash
            end
          end
        end
      end
    end
  end

  context 'importing & reopening' do
    specify 'works, basically' do
      boring_sandwich = {
        bread: 'multi-grain',
        meat: 'roast beast',
        cheese: 'swiss'
      }

      awesome_sandwich = {
        bread: 'sourdough',
        meat: ['roast beast', 'salami', 'turkey'],
        cheese: 'cheddar'
      }

      post('/boring_sandwich', {ingredients: boring_sandwich.to_json}) do |response|
        response.status.should == 200
      end

      post('/awesome_sandwich', {ingredients: awesome_sandwich.to_json}) do |response|
        response.status.should == 200
      end

      post('/another_boring_sandwich', {ingredients: awesome_sandwich.to_json}) do |response|
        response.status.should == 404
      end

      post('/another_boring_sandwich', {ingredients: boring_sandwich.to_json}) do |response|
        response.status.should == 200
      end
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

  context 'mixed input' do
    specify 'is fine' do
      valid = {
        hsh: {
          zim: 'ok',
          zam: 'sweet'
        }.to_json,
        ary: ['one', 'three'].join('|')
      }

      get('/mixed', valid).status.should == 200
      JSON.parse(get('/mixed', valid.except(:ary)).body)['errors']['/mixed'].should == {
        'ary' => 'missing_required_param'
      }
    end

    specify 'hashes can have & and = and ? in them' do
      valid = {
        hsh: {
          zim: 'ok?',
          zam: 'swe&et=omg'
        }.to_json,
        ary: ['one', 'three'].join('|')
      }

      get('/mixed', valid).status.should == 200
    end
  end

  context "eli's bug" do
    specify 'omitted optional hashes are OK' do
      post('/elis_bug', {hash: {id: 1}.to_json}) do |response|
        response.status.should == 200
      end

      post('/elis_bug') do |response|
        JSON.parse(response.body)['errors'].should == nil
        response.status.should == 200
      end
    end
  end
end