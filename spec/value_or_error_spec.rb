require 'spec_helper'

describe Dzl::ValueOrError do
  it 'can be initialized with value or error but not both' do
    expect {
      Dzl::ValueOrError.new(value: 1)

      Dzl::ValueOrError.new(error: 2)
    }.to_not raise_exception

    expect {
      Dzl::ValueOrError.new(value: 3, error: 4)
    }.to raise_exception
  end

  it "knows whether it's a value or an error" do
    v = Dzl::ValueOrError.new(value: 5)
    e = Dzl::ValueOrError.new(error: 6)

    (e.error? && v.value?).should == true
    (v.error? && e.value?).should == false

    v.value.should == 5
    e.error.should == 6

    e.value.should == nil
    v.error.should == nil
  end

  it 'allows v: and e: shortcuts in initializer hash' do
    e = Dzl::ValueOrError.new(e: 7)
    e.error.should == 7

    v = Dzl::ValueOrError.new(v: 8)
    v.value.should == 8
  end

  it 'accepts nil as a valid value' do
    v = Dzl::ValueOrError.new(v: nil)

    v.value?.should == true
    v.value.should == nil
  end
end