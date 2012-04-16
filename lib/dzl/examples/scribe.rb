require 'dzl/examples/base'

class Dzl::Examples::Scribe < Dzl::Examples::Base
  defaults do
    array_separator '|'
  end

  endpoint '/series', :get, :post do
    required(:actions) { type Array }
  end
end