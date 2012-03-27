require 'bundler/setup'
require 'dzl'
Bundler.require

favicon_app = lambda do |env|
  [200, {'Content-Type' => 'text/html'}, ['OK']]
end

map '/favicon.ico' do
  run favicon_app
end

# require 'dzl/examples/trey'
# map '/' do
#   run Dzl::Examples::Trey
# end

# require 'dzl/examples/fun_with_params'
# map '/' do
#   run Dzl::Examples::FunWithParams
# end

# require 'dzl/examples/fun_with_requests'
# map '/' do
#   run Dzl::Examples::FunWithRequests
# end

# require 'dzl/examples/route_profile'
# map '/' do
#   run Dzl::Examples::RouteProfile
# end

# require 'dzl/examples/fun_with_handlers'
# map '/' do
#   run Dzl::Examples::FunWithHandlers
# end

# require 'dzl/examples/fun_with_hooks'
# map '/' do
#   run Dzl::Examples::FunWithHooks
# end

# require 'dzl/examples/fun_with_scopes'
# map '/' do
#   run Dzl::Examples::FunWithScopes
# end

require 'dzl/examples/fun_with_hashes'
map '/' do
  run Dzl::Examples::FunWithHashes
end