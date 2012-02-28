require 'spec_helper'

describe Diesel::DSL do
  it "isn't broken right now" do
    class TestApp
      include Diesel
      app_name :app_one

      pblock :first, stuff: true do
        required :name do
          matches(/kyle/)
        end

        optional :awesomeness do
          allowed_values %w{high medium low}
        end
      end

      endpoint :this do
        required :id do
          integer
        end

        import_pblock :first
        required :awesomeness do
          allowed_values %w{}
        end
      end

      endpoint :that do
        import_pblock :first
      end
    end

    TestApp._router.pblocks.has_key?(:first).should == true
    TestApp._router.pblocks[:first].params.has_key?(:name).should == true
    TestApp._router.pblocks[:first].params[:name].opts[:required].should == true
    TestApp._router.pblocks[:first].params[:awesomeness].opts[:required].should == false
    TestApp._router.routes[:this].pblock.params[:awesomeness].opts[:required].should == true
    TestApp._router.routes[:that].pblock.params[:awesomeness].opts[:required].should == false
    TestApp._router.routes[:this].pblock.params[:id].instance_variable_get(:@validations)[:matches][0].should == /\d+/
  end
end