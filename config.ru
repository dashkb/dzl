require 'bundler/setup'
require 'diesel'
require 'diesel/examples/app'

Bundler.require

use Rack::Reloader

favicon_app = lambda do |env|
  [200, {'Content-Type' => 'text/html'}, ['OK']]
end

map '/favicon.ico' do
  run favicon_app
end

map '/' do
  run Diesel::Examples::RouteProfile
end