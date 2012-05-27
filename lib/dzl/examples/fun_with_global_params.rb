require 'dzl/examples/base'

class Dzl::Examples::FunWithGlobalParams < Dzl::Examples::Base
  defaults do
    content_type 'application/json'
  end

  global_pblock do 
    protect do
      api_key header: 'x_api_key', valid_keys: ['valid-key']
    end                        
    required(:number) {type Fixnum}
  end

  post '/globally_protected'
end
