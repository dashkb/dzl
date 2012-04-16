require 'dzl/examples/base'

class Dzl::Examples::FunWithPblocks < Dzl::Examples::Base
  pblock :foo do
    required :ary do
      type Array
      size == 2
    end
  end

  pblock :bar do
    import_pblock :foo

    required :ary do
      size == 4
    end
  end

  get '/foo' do
    import_pblock :foo
  end

  get '/bar' do
    import_pblock :bar
  end

  get '/'
end