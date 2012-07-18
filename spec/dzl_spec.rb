require 'spec_helper'

class Rootless
  include Dzl
end

describe Rootless do
  describe '.root' do
    it 'should be the current working directory' do
      Rootless.root.should == ENV['PWD']
    end
  end
end