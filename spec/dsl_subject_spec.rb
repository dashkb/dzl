require 'spec_helper'

describe Distil::DSLSubject do
  it 'forwards DSL methods to its DSL proxy' do
    Distil::DSLSubject.any_instance.should_not_receive(:required)
    Distil::DSLProxies::ParameterBlock.any_instance.should_receive(:required).once

    class DSLTest < Distil::Examples::Base
      pblock :foo do
        required :bar
      end
    end
  end
end