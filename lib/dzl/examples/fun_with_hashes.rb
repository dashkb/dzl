require 'dzl/examples/base'

class Dzl::Examples::FunWithHashes < Dzl::Examples::Base
  post '/h' do
    required :foo do
      type Hash, validator: HashValidator.new do
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
  end
end
