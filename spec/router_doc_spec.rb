require 'spec_helper'
require 'dzl/examples/base'
require 'rack/test'

def app; Dzl::Examples::FunWithParams; end

def file_mock
  mock_file = mock "File"
  mock_file.stub!(:write).with(anything).and_return(true)
  mock_file.stub!(:close).and_return(true)
  File.stub!(:new).and_return(mock_file)
end

describe 'router doc functionality' do
  it 'should use a template to generate markdown' do
    File.should_receive(:read).with("./lib/dzl/doc/templates/home.erb").and_return("")

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
