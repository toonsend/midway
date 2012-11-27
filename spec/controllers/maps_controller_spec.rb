require 'spec_helper'

describe MapsController do

  it "can route to maps and game" do
    { :get => "/teams/13/maps" }.should be_routable
    { :get => "/teams/13/maps" }.should route_to("controller" => "maps", "action" => "index", "team_id" => "13")
    { :post => "/teams/13/maps" }.should be_routable
    { :post => "/teams/13/maps" }.should route_to("controller" => "maps", "action" => "create", "team_id" => "13")
  end


  describe "maps#index with valid key" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      @user.generate_api_key!
      request.env['HTTP_MIDWAY_API_KEY'] = @user.api_key
    end

    it "can get maps with valid api key" do
      #TODO implement this when maps api will be ready
      get :index, :team_id => @user.id
      response.should be_success
      res = JSON::parse(response.body)
      res["error_code"].should == "BADLY_FORMED_REQUEST"
    end

  end

  describe "map uploading" do

    it "gets error when trying to upload map without proper api key" do
      request.env['HTTP_MIDWAY_API_KEY'] = "INVALID"
      post :create, {:team_id => 6, :grid => []}
      response.status.should == 200
      res = JSON::parse(response.body)
      res["error_code"].should == "INVALID_API_KEY"
      res["message"].should == "The api key does not match the team_id"
    end

    it "can upload map with valid api key" do
      user = FactoryGirl.create(:user)
      user.generate_api_key!
      request.env['HTTP_MIDWAY_API_KEY'] = user.api_key
      post :create, {:team_id => user.id, :grid => []}
      response.status.should == 200
      res = JSON::parse(response.body)
      res["error_code"].should == "BADLY_FORMED_REQUEST"
    end

  end

end
