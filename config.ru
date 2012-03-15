require 'bundler/setup'
require 'dzl'
Bundler.require

favicon_app = lambda do |env|
  [200, {'Content-Type' => 'text/html'}, ['OK']]
end

map '/favicon.ico' do
  run favicon_app
end

# require 'distil/examples/trey'
# map '/' do
#   run Dzl::Examples::Trey
# end

# require 'distil/examples/fun_with_params'
# map '/' do
#   run Dzl::Examples::FunWithParams
# end

# require 'distil/examples/fun_with_requests'
# map '/' do
#   run Dzl::Examples::FunWithRequests
# end

# require 'distil/examples/route_profile'
# map '/' do
#   run Dzl::Examples::RouteProfile
# end

# require 'distil/examples/fun_with_handlers'
# map '/' do
#   run Dzl::Examples::FunWithHandlers
# end

require 'distil/examples/fun_with_hooks'
map '/' do
  run Dzl::Examples::FunWithHooks
end