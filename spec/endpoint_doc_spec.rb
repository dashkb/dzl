require 'spec_helper'
require 'distil/examples/base'
require 'rack/test'

def app; Distil::Examples::FunWithParams; end

describe 'endpoint doc functionality' do
  it 'should use a template to generate markdown' do
    File.should_receive(:read).with("./lib/distil/doc/templates/home.erb").and_return("")

    app.__router.to_md
  end

  it 'asks endpoints to generate thier docs' do
    file_mock
    app.__router.endpoints.each do |endpoint|
      endpoint.should_receive(:to_md).and_return("")
    end

    app.__router.should_receive(:to_md).with("FunWithParams", anything).and_return("")
    app.__router.should_receive(:'`').with(/FunWithParams/).and_return(nil)

    app.__router.to_docs
  end
end
