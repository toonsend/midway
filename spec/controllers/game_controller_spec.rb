require 'spec_helper'

describe GameController do

  it "routes properly" do
    { :post => "/teams/4/game" }.should be_routable
    { :post => "/teams/4/game" }.should route_to("controller" => "game", "action" => "create", "team_id" => "4")
  end


  describe "game moves" do

    context "with invalid api key" do

      it "gets error when doing move " do
        request.env['HTTP_MIDWAY_API_KEY'] = "INVALID"
        post :create, :team_id => 5
        response.status.should == 200
        res = JSON::parse(response.body)
        res["error_code"].should == "INVALID_API_KEY"
        res["message"].should == "The api key does not match the team_id"        
      end

    end

    context "with valid api key" do
      
      before(:each) do
        @user = FactoryGirl.create(:user)
        @user.generate_api_key!
      end

      it "can make move!" do
        request.env['HTTP_MIDWAY_API_KEY'] = @user.api_key
        post :create, :team_id => @user.id, :move =>[200, 100]
        response.status.should == 200
        res = JSON::parse(response.body)
        res["error_code"].should == "OUT_OF_RANGE"
        res["message"].should == "move is outside of map"
      end

    end

  end

end
