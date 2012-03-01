require 'spec_helper'
require 'rack/test'

describe 'trey support' do
  include Rack::Test::Methods

  def app; Diesel::Examples::App; end

  describe '/page_insights' do
    req_params = {
      page_ids: [1, 2, 3].join(' '),
      metrics: ['m1', 'm2'].join(' '),
      since: '2012-01-01',
      until: '2012-02-01'
    }

    opt_params = {
      interval: 'week'
    }

    bad_params = {
      post_ids: [4, 5, 6].join(' '),
      limit: 100,
      sort: 'these',
      order: 'descending'
    }

    it "responds 404 to a request with no parameters" do
      get '/page_insights' do |response|
        response.status.should == 404
        errors = JSON.parse(response.body)['errors']['/page_insights']
        errors.size.should == 4 # required params
        errors.values.each {|v| v.should == 'missing_required_param'}
      end
    end

    it "responds 404 with only optional parameters" do
      get('/page_insights', opt_params) do |response|
        response.status.should == 404
        errors = JSON.parse(response.body)['errors']['/page_insights']
        errors.size.should == 4 # required params
        errors.values.each {|v| v.should == 'missing_required_param'}
      end
    end

    it "responds 404 if extra, unknown parameters are provided" do
      get('/page_insights', req_params.merge(foo: 'bar')) do |response|
        JSON.parse(response.body).has_key?('foo').should == false
        response.status.should == 404
      end
    end

    it "responds 200 to a request with required parameters provided" do
      get('/page_insights', req_params) do |response|
        response.status.should == 200
      end
    end

    it "allows optional parameters in addition to the required params" do
      get('/page_insights', req_params.merge(opt_params)) do |response|
        response.status.should == 200
      end
    end

    it "sets omitted optional parameters to their default values" do
      get('/page_insights', req_params) do |response|
        JSON.parse(response.body)['interval'].should == 'day'
      end
    end

    it "understands array parameters" do
      get('/page_insights', req_params) do |response|
        response.status.should == 200
        JSON.parse(response.body)['page_ids'].should == ['1', '2', '3']
      end
    end

    it "understands date parameters" do
      get('/page_insights', req_params) do |response|
        response.status.should == 200
        JSON.parse(response.body)['since'].should == '2012-01-01'
      end
    end

    it "understands time parameters" do
      get('/page_insights', req_params.merge({
          since:"#{req_params[:since]}T00:00:00-05:00",
          until:"#{req_params[:until]}T00:00:00-05:00",
        })) do |response|
        response.status.should == 200
        JSON.parse(response.body)['since'].should == '2012-01-01'
      end
    end

    it "responds 404 to a request with required parameters improperly formatted" do
      get('/page_insights', req_params.merge(since: 'not a date')) do |response|
        response.status.should == 404
        errors = JSON.parse(response.body)['errors']['/page_insights']
        errors.size.should == 1
        errors.values.each {|v| v.should == 'type_conversion_error'}
      end
    end

    it "checks array length conditions" do
      get('/page_insights', req_params.merge(page_ids: [1, 2, 3, 4, 5, 6].join(' '))) do |response|
        response.status.should == 404
        errors = JSON.parse(response.body)['errors']['/page_insights']
        errors.size.should == 1
        errors.values.each {|v| v.should == 'validator_object_failed'}
      end
    end

    it "validates that only allowed parameters are accepted" do
      get('/page_insights', req_params.merge(metrics:['not_allowed'])) do |response|
        response.status.should == 404
        errors = JSON.parse(response.body)['errors']['/page_insights']
        errors.size.should == 1
        errors.values.each {|v| v.should == 'allowed_values_failed'}
      end
    end

    it "transforms params prior to validation" do
      get('/posts', req_params.merge(sort:'m1', order:'ASC')) do |response|
        #puts JSON.parse(response.body)['errors']['/posts']
        response.status.should == 200
        JSON.parse(response.body)['order'].should == 'asc'
      end
    end
  end
end