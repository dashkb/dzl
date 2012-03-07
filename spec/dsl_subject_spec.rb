require 'spec_helper'

describe Diesel::DSLSubject do
  it 'forwards DSL methods to its DSL proxy' do
    Diesel::DSLSubject.any_instance.should_not_receive(:required)
    Diesel::DSLProxies::ParameterBlock.any_instance.should_receive(:required).once

    class DSLTest < Diesel::Examples::Base
      pblock :foo do
        required :bar
      end
    end
  end
end