require 'spec_helper'

describe TeamsController do

  it "can route to team" do
    { :post => "/teams" }.should be_routable
    { :post => "/teams" }.should route_to("controller" => "teams", "action" => "create")
  end

  describe "#create with anonymous user" do
    it "should be redirected to the sign in page" do
      post :create
      response.should redirect_to new_user_session_path
    end
  end

  describe "#create with authenticated user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @user.generate_api_key!
      sign_in @user
    end

    it "should not create a team if the team name is blank" do
      lambda {
        post :create
      }.should_not change(Team, :count).by(1)
      @user.reload
      @user.team.should be_nil
      response.should redirect_to key_path
    end

    it "should create a new team" do
      lambda {
        post :create, :team => { :name => "Best team"}
      }.should change(Team, :count).by(1)
      response.should redirect_to key_path
    end

    it "should set the current user as part of the team" do
      post :create, :team => { :name => "Best team"}
      @user.reload
      @user.team.should == Team.find_by_name("Best team")
      response.should redirect_to key_path
    end
  end

end
