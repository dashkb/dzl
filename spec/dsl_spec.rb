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

      def self.router
        @_router
      end
    end

    TestApp.router[:pblocks][:first].params[:name].opts[:required].should == true
    TestApp.router[:pblocks][:first].params[:awesomeness].opts[:required].should == false
    TestApp.router[:endpoints][:this].pblock.params[:awesomeness].opts[:required].should == true
    TestApp.router[:endpoints][:that].pblock.params[:awesomeness].opts[:required].should == false
    TestApp.router[:endpoints][:this].pblock.params[:id].instance_variable_get(:@validations)[:matches][0].should == /\d+/
  end
end