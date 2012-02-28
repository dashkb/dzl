require 'bundler/setup'
require 'diesel'
require 'diesel/examples/app'

use Rack::Reloader
run Diesel::Examples::App