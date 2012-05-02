require 'dzl/examples/base'

class Dzl::Examples::FunWithHashes < Dzl::Examples::Base
  post '/h' do
    required :foo do
      type Hash
      required :str
      required :ary do
        type Array
        allowed_values [3, 5, 7]
      end

      required :nest do
        type Hash
        required(:int) { type Fixnum }
      end
    end
  end

  post '/mixed', :get do
    required :hsh do
      type Hash
      required :zim, :zam
    end

    required :ary do
      type Array, separator: '|'
      allowed_values %w{one two three}
    end
  end

  pblock :ingredients do
    required :ingredients do
      type Hash
      required :cheese, :meat, :bread
    end
  end

  post '/boring_sandwich' do
    import_pblock :ingredients
  end

  post '/awesome_sandwich' do
    import_pblock :ingredients
    parameter :ingredients do
      required(:meat) { type Array }
    end
  end

  post '/another_boring_sandwich' do
    import_pblock :ingredients
  end
end
