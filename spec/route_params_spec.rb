require 'spec_helper'

describe 'route parameters' do
  it 'cannot be set to optional' do
    expect {
      class TestApp1
        include Diesel

        endpoint '/foo/:bar' do
          optional :bar
        end
      end
    }.to raise_error(Diesel::ParameterError)
  end
end