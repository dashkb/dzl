require 'spec_helper'
require 'dzl/examples/base'
require 'rack/test'

class LogTestApp < Dzl::Examples::Base
  get '/log_me' do
    required :msg

    handle do
      logger.success.debug "message is #{params[:msg]}"
    end
  end
end

describe 'Modules including Dzl' do
  it 'should have a logger object provided by Dzl' do
    l = Dzl::Examples::Base.__logger.class.should == Dzl::Logger
  end

  it 'should use their own logger if it is provided' do
    app = Class.new do
      def self.root
        '/'
      end

      def self.logger
        @l ||= ActiveSupport::BufferedLogger.new('/dev/null', ::Logger::DEBUG)
      end

      include Dzl
    end

    app.__logger.class.should == ActiveSupport::BufferedLogger
  end
end

describe 'LogTestApp' do
  include Rack::Test::Methods

  def app; LogTestApp; end

  it 'drops logs' do
    get('/log_me?msg=success')
    last_response.status.should == 200

    `tail -n 1 #{LogTestApp.root}/log/success.test.log`.match('success').should_not == nil
  end
end