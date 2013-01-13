require 'spec_helper'

describe GameController do

  it "routes properly" do
    { :post => "/teams/4/game" }.should be_routable
    { :post => "/teams/4/game" }.should route_to("controller" => "game", "action" => "create", "team_id" => "4")
  end


  describe "game moves" do

    it "gets error when trying to upload map without having set a team" do
      request.env['HTTP_MIDWAY_API_KEY'] = "WHATEVER"
      post :create, {:team_id => 6, :move => [200, 100]}
      response.status.should == 404
      res = JSON::parse(response.body)
      res["error_code"].should == "TEAM_NOT_FOUND"
      res["message"].should == "Team not found"
    end

    it "gets error when doing move with an invalid api key" do
      team = FactoryGirl.create(:team)
      request.env['HTTP_MIDWAY_API_KEY'] = "INVALID"
      post :create, :team_id => team.id
      response.status.should == 200
      res = JSON::parse(response.body)
      res["error_code"].should == "INVALID_API_KEY"
      res["message"].should == "The api key does not match the team_id"
    end

    context "with valid api key" do

      before(:each) do
        @user = FactoryGirl.create(:user, :with_team)
        @user.generate_api_key!
        @team = @user.team
      end

      it "should return a NO_GAME error if there's no maps to play against" do
        request.env['HTTP_MIDWAY_API_KEY'] = @user.api_key
        post :create, :team_id => @team.id, :move => [200, 100]
        response.status.should == 422
        res = JSON::parse(response.body)
        res["error_code"].should == "NO_GAME"
        res["message"].should == "There is currently no game to play"
      end

      it "should return a NO_MAPS_UPLOADED error if the user hasn't uploaded a map yet" do
        opponent_team = FactoryGirl.create(:team)
        FactoryGirl.create(:map, :team_id => opponent_team.id)
        request.env['HTTP_MIDWAY_API_KEY'] = @user.api_key
        post :create, :team_id => @team.id, :move => [200, 100]
        response.status.should == 422
        res = JSON::parse(response.body)
        res["error_code"].should == "NO_MAPS_UPLOADED"
        res["message"].should == "Your team does not have any maps so can not enter tournament"
      end

      it "should return an INVALID_MOVE error if an invalid move is submitted" do
        FactoryGirl.create(:map, :team_id => @team.id)
        FactoryGirl.create(:map, :team_id => 2)
        request.env['HTTP_MIDWAY_API_KEY'] = @user.api_key
        post :create, :team_id => @team.id, :move => [200, [100]]
        response.status.should == 422
        res = JSON::parse(response.body)
        res["error_code"].should == "INVALID_MOVE"
        res["message"].should == "Invalid move"
      end

      it "should return the move state if the move is valid" do
        FactoryGirl.create(:map, :team_id => @team.id)
        opponent_team = FactoryGirl.create(:team)
        FactoryGirl.create(:map, :team_id => opponent_team.id)
        request.env['HTTP_MIDWAY_API_KEY'] = @user.api_key
        post :create, :team_id => @team.id, :move => [0, 0]
        response.status.should == 200
        res = JSON::parse(response.body)
        res["opponent_id"].should == opponent_team.id
        res["move"].should == [0,0]
      end

    end

  end

end
