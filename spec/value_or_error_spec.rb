require 'spec_helper'

describe Diesel::ValueOrError do
  it 'can be initialized with value or error but not both' do
    expect {
      Diesel::ValueOrError.new(value: 1)

      Diesel::ValueOrError.new(error: 2)
    }.to_not raise_exception

    expect {
      Diesel::ValueOrError.new(value: 3, error: 4)
    }.to raise_exception
  end

  it "knows whether it's a value or an error" do
    v = Diesel::ValueOrError.new(value: 5)
    e = Diesel::ValueOrError.new(error: 6)

    (e.error? && v.value?).should == true
    (v.error? && e.value?).should == false

    v.value.should == 5
    e.error.should == 6

    e.value.should == nil
    v.error.should == nil
  end

  it 'allows v: and e: shortcuts in initializer hash' do
    e = Diesel::ValueOrError.new(e: 7)
    e.error.should == 7

    v = Diesel::ValueOrError.new(v: 8)
    v.value.should == 8
  end

  it 'accepts nil as a valid value' do
    v = Diesel::ValueOrError.new(v: nil)

    v.value?.should == true
    v.value.should == nil
  end
end