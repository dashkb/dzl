require 'bundler/setup'
require 'diesel'

ENV['RACK_ENV'] ||= 'test'

RSpec.configure do |config|
  config.mock_with :rspec
end