require 'dzl/examples/base'

module Dzl::Examples::MultiFile
  class App < Dzl::Examples::Base
    get '/one' do
      handle do
        'one'
      end
    end

    pblock :import do
      required :foo
    end
  end
end
