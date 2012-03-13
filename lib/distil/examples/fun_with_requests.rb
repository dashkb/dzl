require 'distil/examples/base'

class Distil::Examples::FunWithRequests < Distil::Examples::Base 
  endpoint '/foo' do
    handle do
      'get'
    end
  end

  endpoint '/post_op', :post do
    handle do
      'post'
    end
  end

  endpoint '/multi_op', :post, :put do
    handle do
      request.request_method.downcase
    end
  end

  get '/get_only'
  delete '/delete_only'
  get '/get_and_post', :post

  get '/validated_header' do
    required_header :key do
      validate_with { |k| k == 'hello' }
    end
  end

  get '/ambiguous' do
    required :foo

    handle do
      params[:foo]
    end
  end

  get '/ambiguous' do
    required :bar

    handle do
      params[:bar]
    end
  end
end