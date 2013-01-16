require 'spec_helper'

describe TeamsController do

  it "can route to team" do
    { :get => "/teams" }.should be_routable
    { :get => "/teams" }.should route_to("controller" => "teams", "action" => "index")
    { :post => "/teams" }.should be_routable
    { :post => "/teams" }.should route_to("controller" => "teams", "action" => "create")
  end

  describe "#index with anonymous user" do
    it "should be redirected to the sign in page" do
      get :index
      response.should redirect_to new_user_session_path
    end
  end

  describe "#index with authenticated user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @user.generate_api_key!
      sign_in @user
    end

    it "should render index template" do
      get :index
      response.should render_template("index")
      response.response_code.should eq(200)
    end

    describe "when current user does NOT have a team" do
      it "should assign team as a new record" do
        get :index
        assigns(:team).should_not be_nil
        assigns(:team).new_record?.should be_true
      end
    end

    describe "when current user has a team" do
      before(:each) do
        @user = FactoryGirl.create(:user, :with_team)
        @user.generate_api_key!
        sign_in @user
      end

      it "should assign team with the current user's team" do
        get :index
        assigns(:team).should_not be_nil
        assigns(:team).should eq(@user.team)
      end

      # it "should assign invite with a new record that has the current user's team as the inviter" do
      #   get :index
      #   assigns(:invite).should_not be_nil
      #   assigns(:invite).team.should eq(@user.team)
      # end

      it "should assign users with a list of users the current user's team can invite" do
        # controller.current_user.team.should_receive(:users_to_invite).with(@user)
        get :index
        assigns(:users).should_not be_nil
        assigns(:users).should be_kind_of(Array)
        assigns(:users).should eq(@user.team.users_to_invite(@user))
      end
    end
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
      response.should redirect_to teams_path
    end

    it "should create a new team" do
      lambda {
        post :create, :team => { :name => "Best team"}
      }.should change(Team, :count).by(1)
      response.should redirect_to teams_path
    end

    it "should set the current user as part of the team" do
      post :create, :team => { :name => "Best team"}
      @user.reload
      @user.team.should == Team.find_by_name("Best team")
      response.should redirect_to teams_path
    end
  end

end
