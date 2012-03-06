module Diesel::Examples; end

class Diesel::Examples::FunWithRequests
  include Diesel

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
end