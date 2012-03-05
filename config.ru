require 'bundler/setup'
require 'diesel'
Bundler.require

use Rack::Reloader

favicon_app = lambda do |env|
  [200, {'Content-Type' => 'text/html'}, ['OK']]
end

map '/favicon.ico' do
  run favicon_app
end

# require 'diesel/examples/trey'
# map '/' do
#   run Diesel::Examples::Trey
# end

# require 'diesel/examples/fun_with_params'
# map '/' do
#   run Diesel::Examples::FunWithParams
# end

# require 'diesel/examples/route_profile'
# map '/' do
#   run Diesel::Examples::RouteProfile
# end

require 'diesel/examples/fun_with_handlers'
map '/' do
  run Diesel::Examples::FunWithHandlers
end