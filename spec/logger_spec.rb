require 'spec_helper'
require 'diesel/examples/base'

describe 'Modules including Diesel' do
  it 'should have a logger object provided by Diesel' do
    l = Diesel::Examples::Base.__logger.class.should == Diesel::Logger
  end

  it 'should use their own logger if it is provided' do
    app = Class.new do
      def self.root
        '/'
      end

      def self.logger
        @l ||= ActiveSupport::BufferedLogger.new('/dev/null', ::Logger::DEBUG)
      end

      include Diesel
    end

    app.__logger.class.should == ActiveSupport::BufferedLogger
  end
end