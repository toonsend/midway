require 'spec_helper'

describe InvitesController do

  it "can route to invites" do
    { :post => "/invites" }.should be_routable
    { :post => "/invites" }.should route_to("controller" => "invites", "action" => "create")
    { :put => "/invites/1" }.should be_routable
    { :put => "/invites/1" }.should route_to("controller" => "invites", "action" => "update", "id" => "1")
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

  describe "#update with anonymous user" do
    it "should be redirected to the sign in page" do
      put :update, id: 1
      response.should redirect_to new_user_session_path
    end
  end

  describe "#update with authenticated user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @user.generate_api_key!
      sign_in @user
    end

    it "should NOT add current user to inviter team if invite doesn't exist" do
      put :update, id: 1
      response.should redirect_to key_path
      @user.team.should be_nil
    end

    it "should NOT add current user to inviter team if the request is invalid" do
      invite = FactoryGirl.create(:invite, user: @user)
      put :update, id: invite.id, submit: 'invalid'
      response.should redirect_to key_path
      invite.reload
      invite.state.should == 'pending'
      @user.team.should be_nil
    end

    it "should NOT add current user to inviter team if the invite is not him" do
      other_user = FactoryGirl.create(:user)
      invite = FactoryGirl.create(:invite, user: other_user)
      put :update, id: invite.id, submit: 'accept'
      response.should redirect_to key_path
      invite.reload
      invite.state.should == 'pending'
      @user.team.should be_nil
    end

    it "should NOT add current user to inviter team if user already belongs to a team" do
      user = FactoryGirl.create(:user, :with_team)
      sign_in user
      invite = FactoryGirl.create(:invite, user: user)
      put :update, id: invite.id, submit: 'accept'
      response.should redirect_to key_path
      invite.reload
      invite.state.should == 'pending'
      user.team.should_not == invite.team
    end

    it "should NOT add current user to inviter team if he declined the invite" do
      invite = FactoryGirl.create(:invite, user: @user)
      put :update, id: invite.id, submit: 'decline'
      response.should redirect_to key_path
      invite.reload
      invite.state.should == 'declined'
      @user.team.should be_nil
    end

    it "should add current user to inviter team if he accepted the invite" do
      invite = FactoryGirl.create(:invite, user: @user)
      put :update, id: invite.id, submit: 'accept'
      response.should redirect_to key_path
      invite.reload
      invite.state.should == 'accepted'
      @user.reload
      @user.team_id.should == invite.inviter
    end
  end
end
