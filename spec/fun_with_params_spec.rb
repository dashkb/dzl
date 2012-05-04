require 'spec_helper'
require 'rack/test'
require 'dzl/examples/fun_with_params'

describe Dzl::Examples::FunWithParams do
  include Rack::Test::Methods

  def app; Dzl::Examples::FunWithParams; end

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

    describe "required parameters" do
      it "arrays cannot be empty" do
        get('/foo', {foo: ''}) do |response|
          response.status.should == 404
          JSON.parse(response.body)['errors']['/foo'].should == {
            'foo' => 'empty_required_array'
          }
        end
      end

      it "strings cannot be empty" do
        get('/bar', {foo: ''}) do |response|
          response.status.should == 404
          JSON.parse(response.body)['errors']['/bar'].should == {
            'foo' => 'missing_required_param'
          }
        end
      end
    end

    describe "arbitrary array separator" do
      it "can split arrays on +" do
        ary = %w{one two three}
        bad = ary.join(' ')
        good = ary.join('+')

        get('/bar', {foo: bad}) do |response|
          response.status.should == 200
          JSON.parse(response.body)['params']['foo'].should == ['one two three']
        end

        get('/bar', {foo: good}) do |response|
          response.status.should == 200
          JSON.parse(response.body)['params']['foo'].should == ary
        end
      end
    end

    it "can split arrays on ," do
      ary = %w{one two three}
      bad = ary.join(' ')
      good = ary.join(',')

      get('/baz', {foo: bad}) do |response|
        response.status.should == 200
        JSON.parse(response.body)['params']['foo'].should == ['one two three']
      end

      get('/baz', {foo: good}) do |response|
        response.status.should == 200
        JSON.parse(response.body)['params']['foo'].should == ary
      end
    end
  end

  describe '/foo/:bar (:bar as string)' do
    it 'finds :bar properly' do
      get '/foo/omg' do |response|
        response.status.should == 200
        JSON.parse(response.body)['params']['bar'].should == 'omg'
      end
    end
  end

  describe '/foo/:bar (:bar as time)' do
    it 'converts :bar to time' do
      get '/foo/2012-01-01' do |response|
        response.status.should == 200
        Time.parse(JSON.parse(response.body)['params']['bar']).should == Time.parse('2012-01-01T00:00:00')
      end
    end
  end

  describe '/bar' do
    it 'should 404 on /bar/anything' do
      get('/bar/foo') {|r| r.status.should == 404}
    end
  end

  describe '/protected' do
    it 'should present http basic challenge with no credentials' do
      get '/protected' do |response|
        response.status.should == 401
      end

      post '/other_protected', foo: 'present' do |response|
        response.status.should == 401
      end

      get '/other_protected' do |response|
        response.status.should == 401
      end
    end

    it 'should present the http basic challenge with invalid credentials' do
      authorize('wrong', 'values')
      get '/protected' do |response|
        response.status.should == 401
      end
    end

    it 'should process normally if credentials are correct' do
      authorize('no', 'way')
      get '/protected' do |response|
        response.status.should == 200
      end

      post '/other_protected', foo: 'present' do |response|
        response.status.should == 200
      end
    end

    it 'should 404 with valid auth and bad params' do
      authorize('no', 'way')
      post '/other_protected' do |response|
        response.status.should == 404
      end

      get '/other_protected' do |response|
        response.status.should == 404
      end
    end

    it 'should 401 with invalid auth' do
      get '/other_protected' do |response|
        response.status.should == 401
      end
    end
  end

  describe '/api' do
    it 'should 401 if no api key provided' do
      get '/api'
      last_response.status.should == 401
    end

    it 'should 401 if invalid api key provided' do
      get '/api', {}, {"HTTP_X_API_KEY" => 'invalid-key'}
      last_response.status.should == 401
    end

    it 'should accept valid api key' do
      get '/api', {}, {"HTTP_X_API_KEY" => 'valid-key'}
      last_response.status.should == 200
    end
  end

  describe '/api_proc' do
    it 'should 401 if no api key provided' do
      get '/api_proc'
      last_response.status.should == 401
    end

    it 'should 401 if invalid api key provided' do
      get '/api_proc', {}, {"HTTP_X_API_KEY" => 'bad-key'}
      last_response.status.should == 401
    end

    it 'should accept valid api key' do
      get '/api_proc', {}, {"HTTP_X_API_KEY" => 'valid-key'}
      last_response.status.should == 200
    end
  end

  describe '/arithmetic' do
    it 'should not allow :int < 5' do
      get('/arithmetic', {int: 4}) do |response|
        response.status.should == 404
        JSON.parse(response.body)['errors']['/arithmetic'].should == {
          'int' => 'value_validation_failed'
        }
      end

      get('/arithmetic', {int: 5}) do |response|
        response.status.should == 200
      end
    end

    it "is called arithmetic but works on strings" do
      get('/arithmetic', {str: 'goodbye'}) do |response|
        response.status.should == 404
      end

      get('/arithmetic', {str: 'hello'}) do |response|
        response.status.should == 200
      end
    end

    it "also works on dates" do
      get('/arithmetic', {date: '2011-12-25'}) do |response|
        response.status.should == 404
      end

      get('/arithmetic', {date: '2012-01-02'}) do |response|
        response.status.should == 200
      end
    end
  end

  describe '/defaults' do
    it "handles default parameter values correctly" do
      get('/defaults') do |response|
        response.status.should == 200
        JSON.parse(response.body)['params'].should == {
          'foo' => 'hello',
          'baz' => 'world',
          'nil' => nil
        }
      end

      get('/defaults', {foo: 'world', baz: 'hello', bar: 'not nil', nil: 'not nil'}) do |response|
        response.status.should == 200
        JSON.parse(response.body)['params'].should == {
          'foo' => 'world',
          'baz' => 'hello',
          'bar' => 'not nil',
          'nil' => 'not nil'
        }
      end
    end
  end

  describe '/rofl/:copter' do
    it 'infers json-encoded body parameters' do
      example_body = {
        'candy' => [1,3,4],
        'cookies' => 7,
        'steak' => 'eww',
        'sunshine' => 9
      }.to_json
      header "Content-Type", "application/json"
      post('/rofl/haha?more=vars', example_body) do |response|
        response.successful?.should be_true
        params = JSON.parse(response.body)['params']
        params['copter'].should == 'haha'
        params['candy'].should == [1, 3, 4]
        params['sunshine'].should == 9
        params['more'].should == "vars"
      end
    end

    it 'still validates types' do
      example_body = {
        'candy' => 'this-will-be-a-one-element-array',
        'cookies' => ['o', 'o', 'p', 's'],
        'steak' => 'eww',
        'sunshine' => 9
      }.to_json
      header "Content-Type", "application/json"
      post('/rofl/haha?more=vars', example_body) do |response|
        response.successful?.should be_false
        errors = JSON.parse(response.body)['errors']['/rofl/:copter']
        errors.should == {
          'cookies' => 'type_conversion_error',
          'candy' => 'type_conversion_error'
        }
      end
    end

    describe '/body' do
      specify 'works' do
        post('/body', foo: 'hello', bar: 'world') do |response|
          response.status.should == 200
        end
      end
    end
  end
end
