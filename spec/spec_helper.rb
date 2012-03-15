require 'bundler/setup'
require 'dzl'

ENV['RACK_ENV'] ||= 'test'

RSpec.configure do |config|
  config.mock_with :rspec
end