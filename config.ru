require 'bundler/setup'
require 'distil'
Bundler.require

favicon_app = lambda do |env|
  [200, {'Content-Type' => 'text/html'}, ['OK']]
end

map '/favicon.ico' do
  run favicon_app
end

# require 'distil/examples/trey'
# map '/' do
#   run Distil::Examples::Trey
# end

# require 'distil/examples/fun_with_params'
# map '/' do
#   run Distil::Examples::FunWithParams
# end

# require 'distil/examples/fun_with_requests'
# map '/' do
#   run Distil::Examples::FunWithRequests
# end

# require 'distil/examples/route_profile'
# map '/' do
#   run Distil::Examples::RouteProfile
# end

# require 'distil/examples/fun_with_handlers'
# map '/' do
#   run Distil::Examples::FunWithHandlers
# end

require 'distil/examples/fun_with_hooks'
map '/' do
  run Distil::Examples::FunWithHooks
end