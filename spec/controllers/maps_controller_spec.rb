require 'spec_helper'

describe MapsController do

  it "can route to maps and game" do
    { :get => "/teams/13/maps" }.should be_routable
    { :get => "/teams/13/maps" }.should route_to("controller" => "maps", "action" => "index", "team_id" => "13")
    { :post => "/teams/13/maps" }.should be_routable
    { :post => "/teams/13/maps" }.should route_to("controller" => "maps", "action" => "create", "team_id" => "13")
  end

  describe "maps#destroy valid key" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      @user.generate_api_key!
      @team = @user.team
      request.env['HTTP_MIDWAY_API_KEY'] = @user.api_key
      @map  = FactoryGirl.create(:map, :team_id => @team.id)
    end


    it "should return an success" do
      response = delete :destroy, :team_id => @team.id, :id => @map.id
      response.should be_success
    end

    it "should delete a map" do
      lambda {
        delete :destroy, :team_id => @team.id, :id => @map.id
      }.should change(Map, :count).by(-1)
    end

    it "should only delete that team's map" do
      Map.first.update_attribute(:team_id, 33)
      lambda {
        delete :destroy, :team_id => @team.id, :id => @map.id
      }.should_not change(Map, :count)
    end

    it "should only delete the map with that id" do
      lambda {
        delete :destroy, :team_id => @team.id, :id => @map.id + 100
      }.should_not change(Map, :count)
    end

    it "should return a 404 if the map is not found" do
      response = delete :destroy, :team_id => @team.id, :id => @map.id + 100
      response.status.should == 404
    end

    it "should return correct error code" do
      response = delete :destroy, :team_id => @team.id, :id => @map.id + 100
      response = JSON::parse(response.body)
      response["error_code"].should == "MAP_NOT_FOUND"
    end

  end

  describe "maps#index with valid key" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      @user.generate_api_key!
      @team = @user.team
      request.env['HTTP_MIDWAY_API_KEY'] = @user.api_key
    end

    it "can get maps with valid api key" do
      get :index, :team_id => @team.id
      response.should be_success
      res = JSON::parse(response.body)
      res["grids"].should == {}

      3.times { FactoryGirl.create(:map) }
      get :index, :team_id => @team.id
      response.should be_success
      res = JSON::parse(response.body)
      maps = Map.find_all_by_team_id(@team.id)
      res["grids"].should == maps.inject({}) { |mem, map| mem["#{map.id}"]=map.grid;mem }
    end

  end

  describe "map uploading" do

    it "gets error when trying to upload map without having set a team" do
      request.env['HTTP_MIDWAY_API_KEY'] = "WHATEVER"
      post :create, {:team_id => 6, :grid => valid_grid_params}
      response.status.should == 404
      res = JSON::parse(response.body)
      res["error_code"].should == "TEAM_NOT_FOUND"
      res["message"].should == "Team not found"
    end

    it "gets error when trying to upload map without proper api key" do
      team = FactoryGirl.create(:team)
      request.env['HTTP_MIDWAY_API_KEY'] = "INVALID"
      post :create, {:team_id => team.id, :grid => valid_grid_params}
      response.status.should == 200
      res = JSON::parse(response.body)
      res["error_code"].should == "INVALID_API_KEY"
      res["message"].should == "The api key does not match the team_id"
    end

    it "can upload map with valid api key" do
      user = FactoryGirl.create(:user)
      user.generate_api_key!
      request.env['HTTP_MIDWAY_API_KEY'] = user.api_key
      grid_params = JSON.parse(valid_grid_params)
      post :create, {:team_id => user.team.id, :grid => grid_params}
      response.status.should == 200
      res = JSON::parse(response.body)
      res["id"].should == Map.first.id
    end

  end

  describe "when map is invalid" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      @user.generate_api_key!
      @team = @user.team
      request.env['HTTP_MIDWAY_API_KEY'] = @user.api_key
    end

    it "should return not enough ships" do
      grid_params = JSON.parse(valid_grid_params)
      grid_params.delete_at(0)
      post :create, {:team_id => @team.id, :grid => grid_params}
      response.status.should == 422
      res = JSON::parse(response.body)
      res["error_code"].should == "NOT_ENOUGH_SHIPS"
    end

    it "should return too many ships" do
      grid_params = JSON.parse(valid_grid_params)
      grid_params << [6, 2, 4, "across"]
      post :create, {:team_id => @team.id, :grid => grid_params}
      response.status.should == 422
      res = JSON::parse(response.body)
      res["error_code"].should == "TOO_MANY_SHIPS"
    end

    it "should return ships are not of the required size" do
      grid_params = JSON.parse(valid_grid_params)
      grid_params[0] = [0, 0, 4, "down"]
      post :create, {:team_id => @team.id, :grid => grid_params}
      response.status.should == 422
      res = JSON::parse(response.body)
      res["error_code"].should == "WRONG_SHIP_SIZE"
    end

    it "should return ships in collision" do
      grid_params = JSON.parse(valid_grid_params)
      battleship = Ship.new(grid_params[1])
      grid_params[0] = [battleship.xpos, battleship.ypos, 5, battleship.direction]
      post :create, {:team_id => @team.id, :grid => grid_params}
      response.status.should == 422
      res = JSON::parse(response.body)
      res["error_code"].should == "SHIPS_OVERLAP"
    end

    def check_for_invalid_ship(ship)
      grid_params = JSON.parse(valid_grid_params)
      grid_params[0] = ship
      post :create, {:team_id => @user.id, :grid => grid_params}
      response.status.should == 422
      res = JSON::parse(response.body)
      res["error_code"].should == "SHIP_OUT_OF_BOUNDS"
    end

    it "should return ship is positioned outside of map" do
      check_for_invalid_ship([9, 0, 5, 'across'])
    end

    it "should return ship is positioned outside of map" do
      check_for_invalid_ship([1000000, 0, 5, 'down'])
    end

    it "should return ship is positioned outside of map" do
      check_for_invalid_ship([-4, 0, 5, 'across'])
    end

    it "should return ship is positioned outside of map" do
      check_for_invalid_ship([-1, 0, 5, 'down'])
    end



    it "should return badly formed request" do
      post :create, {:team_id => @team.id, :grid => "mooose"}
      response.status.should == 422
      res = JSON::parse(response.body)
      res["error_code"].should == "BADLY_FORMED_REQUEST"
    end

  end

end
