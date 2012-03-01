require 'spec_helper'
require 'rack/test'

class TreyAPI
  include Diesel
  METRIC_NAMES_OR_WHATEVER = %w{m1 m2 m3 m4 m5 m6}

  # this could be handy
  defaults do
    type Array do
      unique
      separator ' '
    end
  end

  # global parameter block applies to all routes
  # each route gets it's own copy, so, they can 
  # mess with the predefined parameters as much as
  # they'd like
  global_pblock do
    required_header :api_key do
      validate_with { |key| key == 'open sesame' }
    end

    param :page_ids do
      type Array
      size <= 25
    end

    param :post_ids do
      type Array
      size <= 100
    end

    param :metrics do
      type Array
      allowed_values TreyAPI::METRIC_NAMES_OR_WHATEVER
    end

    param :since, :until do
      type Time
    end

    param :interval do
      allowed_values %w{day week month}
      default 'day'
    end

    param :limit do
      type Fixnum
      allowed_values 1..250
      default 250
    end

    param :sort do
      begin
        allowed_values params[:metrics]
      rescue Diesel::NYI
        allowed_values [:not, :yet, :implemented]
      end
      default 'created_time'
    end

    param :order do
      downcase
      to_sym
      allowed_values [:asc, :desc, :ascending, :descending]
      default :desc
    end
  end

  endpoint '/page_insights' do
    required :page_ids, :metrics, :since, :until
    optional :interval
    forbid :post_ids, :limit, :sort, :order
  end

  endpoint '/post_insights' do
    required :post_ids, :metrics
    forbid :page_ids, :since, :until, :interval, :limit, :sort, :order
  end

  endpoint '/post_insights' do
    required :page_ids do
      size <= 5
    end

    required :metrics, :since, :until
    forbid :post_ids, :interval, :limit, :sort, :order
  end

  endpoint '/posts' do
    required :page_ids, :metrics
    optional :since, :until, :limit, :sort, :order
    forbid :post_ids
  end

  endpoint '/posts' do
    required :post_ids, :metrics
    optional :since, :until, :limit, :sort, :order
    forbid :page_ids
  end
end



describe 'trey support' do
  include Rack::Test::Methods

  def app; TreyAPI; end

  describe '/page_insights' do
    req_params = {
      page_ids: [1, 2, 3].join(' '),
      metrics: ['these', 'those'].join(' '),
      since: 'yesterday',
      until: 'today'
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

    it "responds 404 to a request with required parameters improperly formatted" do
      get('/page_insights', req_params.merge(page_ids: 'string_not_array')) do |response|
        response.status.should == 404
        errors = JSON.parse(response.body)['errors']['/page_insights']
        errors.size.should == 1
        errors.should == {'page_ids' => 'type_mismatch'}
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

    it "understands array parameters" do
      get('/page_insights', req_params) do |response|
        response.status.should == 200
        JSON.parse(response.body)['page_ids'].should == [1, 2, 3]
      end
    end
  end
end