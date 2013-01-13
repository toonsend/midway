require 'spec_helper'

describe InvitesController do

  it "can route to invites" do
    { :post => "/invites" }.should be_routable
    { :post => "/invites" }.should route_to("controller" => "invites", "action" => "create")
  end

  describe "#create with anonymous user" do
    it "should be redirected to the sign in page" do
      post :create
      response.should redirect_to new_user_session_path
    end
  end

  describe "#create with authenticated user" do
    before(:each) do
      @user = FactoryGirl.create(:user, :with_team)
      @user.generate_api_key!
      sign_in @user
    end

    it "should not create an invite if user does not own a team" do
      inviter = FactoryGirl.create(:user)
      sign_in inviter
      invitee = FactoryGirl.create(:user)
      lambda {
        post :create, invite: { invitee: invitee.id }
        response.should redirect_to key_path
      }.should_not change(Invite, :count).by(1)
    end

    it "should not create an invite if the invitee is blank" do
      lambda {
        post :create, invite: {}
        response.should redirect_to key_path
      }.should_not change(Invite, :count).by(1)
    end

    it "should create an invite" do
      invitee = FactoryGirl.create(:user)
      post :create, invite: { invitee: invitee.id }
      response.should redirect_to key_path
      invite = Invite.find_by_inviter_and_invitee(@user.team.id, invitee.id)
      invite.state.should == 'pending'
    end
  end

end
