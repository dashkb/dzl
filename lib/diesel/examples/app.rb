module Diesel::Examples; end

class Diesel::Examples::App
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
      allowed_values METRIC_NAMES_OR_WHATEVER
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