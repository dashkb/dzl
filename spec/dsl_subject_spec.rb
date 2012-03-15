require 'spec_helper'

describe Dzl::DSLSubject do
  it 'forwards DSL methods to its DSL proxy' do
    Dzl::DSLSubject.any_instance.should_not_receive(:required)
    Dzl::DSLProxies::ParameterBlock.any_instance.should_receive(:required).once

    class DSLTest < Dzl::Examples::Base
      pblock :foo do
        required :bar
      end
    end
  end
end