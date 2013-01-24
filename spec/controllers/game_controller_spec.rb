require 'spec_helper'

describe GameController do

  it "routes properly" do
    { :post => "/teams/4/game" }.should be_routable
    { :post => "/teams/4/game" }.should route_to("controller" => "game", "action" => "create", "team_id" => "4")
  end


  describe "game moves" do

    describe "test game" do

      before(:each) do
        @user = FactoryGirl.create(:user, :with_team)
        @user.generate_api_key!
        @team = @user.team
      end

      it "should get a game" do
        Tournament.stub(:get_game).and_return(Game.new)
        team = FactoryGirl.create(:team)
        request.env['HTTP_MIDWAY_API_KEY'] = @user.api_key
        post :create, :team_id => @team.id, :move => [200, 100]
        assigns(:game).should be_an_instance_of(Game)
      end

      it "should always get a game if test parameter is passed" do
        Team.stub(:get_practice_game).and_return(Game.new)
        team = FactoryGirl.create(:team)
        request.env['HTTP_MIDWAY_API_KEY'] = @user.api_key
        post :create, :team_id => @team.id, :move => [200, 100], :test => true
        assigns(:game).should be_an_instance_of(Game)
      end

    end

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
        Tournament.stub(:get_game).and_raise(NoGameException.new)
        request.env['HTTP_MIDWAY_API_KEY'] = @user.api_key
        post :create, :team_id => @team.id, :move => [200, 100]
        response.status.should == 422
        res = JSON::parse(response.body)
        res["error_code"].should == "NO_GAME"
        res["message"].should == "There is currently no game to play"
      end

      it "should return an INVALID_MOVE error if an invalid move is submitted" do
        Tournament.stub(:get_game).and_return(FactoryGirl.create(:game))
        request.env['HTTP_MIDWAY_API_KEY'] = @user.api_key
        post :create, :team_id => @team.id, :move => [200, [100]]
        response.status.should == 422
        res = JSON::parse(response.body)
        res["error_code"].should == "INVALID_MOVE"
        res["message"].should == "Invalid move"
      end

      it "should return the move state if the move is valid" do
        Tournament.stub(:get_game).and_return(FactoryGirl.create(:game))
        request.env['HTTP_MIDWAY_API_KEY'] = @user.api_key
        post :create, :team_id => @team.id, :move => [0, 0]
        response.status.should == 200
        res = JSON::parse(response.body)
        res["move"].should == [0,0]
      end

    end

  end

end
