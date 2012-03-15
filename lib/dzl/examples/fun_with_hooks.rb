require 'dzl/examples/base'

class Dzl::Examples::FunWithHooks < Dzl::Examples::Base
  defaults do
    content_type 'application/json'
  end

  endpoint '/pre' do
    required :foo do
      type Fixnum
      value >= 4
      prevalidate_transform do |input|
        input == 1 ? 4 : input
      end
    end
  end

  endpoint '/post' do
    required :foo do
      type Fixnum
      value >= 4
    end

    after_validate do
      params[:foo] *= 2
    end
  end

  endpoint '/multiply' do
    required :x, :y do
      type Fixnum
    end

    after_validate do
      params[:z] = params[:x] * params[:y]
    end
  end

  endpoint '/omg_math' do
    optional :x, :y, :z do
      type Fixnum
    end

    optional :prefix

    # NEVER DO THIS IN YOUR APP IT IS SO UGLY
    after_validate do
      params[:multiply_then_add] = params[:x] * params[:y]
    end

    after_validate do
      params[:multiply_then_add] += params[:z]
    end

    after_validate do
      params[:speak] = "#{params[:prefix]} #{params[:multiply_then_add]}"
    end
  end

  endpoint '/vomit' do
    after_validate do
      raise Dzl::BadRequest.new("This isn't quite what I was expecting")
    end
  end
end