require 'spec_helper'

describe Invite do

  describe "#create" do
    it "should require an inviter" do
      invite = FactoryGirl.build(:invite, inviter: nil)
      invite.should_not be_valid
      invite.should have_at_least(1).error_on(:inviter)
      invite.errors[:inviter].should include("can't be blank")
    end

    it "should require an invitee" do
      invite = FactoryGirl.build(:invite, invitee: nil)
      invite.should_not be_valid
      invite.should have_at_least(1).error_on(:invitee)
      invite.errors[:invitee].should include("can't be blank")
    end

    it "should not create an invite if the user has already been invited" do
      team = FactoryGirl.create(:team)
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:invite, team: team, user: user)
      invite = FactoryGirl.build(:invite, team: team, user: user)
      invite.should_not be_valid
      invite.should have_at_least(1).error_on(:invitee)
      invite.errors[:invitee].should include("has already been taken")
    end

    it "should set set invite as pending by default" do
      invite = FactoryGirl.create(:invite)
      invite.state.should == "pending"
    end
  end

  describe "instance" do
    before(:each) do
      @invite = FactoryGirl.create(:invite)
    end

    describe "#accept!" do
      it "should raise an exception if state transition is invalid" do
        @invite.update_attributes(state: 'accepted')
        lambda {
          @invite.accept!
        }.should raise_exception(StateMachine::InvalidTransition)

        @invite.update_attributes(state: 'declined')
        lambda {
          @invite.accept!
        }.should raise_exception(StateMachine::InvalidTransition)
      end

      it "should raise an exception if invitee already has a team" do
        team = FactoryGirl.create(:team)
        @invite.user.team = team
        lambda {
          @invite.accept!
        }.should raise_exception(StateMachine::InvalidTransition)
      end

      it "should set invite as accepted if it's currently pending" do
        @invite.accept!
        @invite.state.should == "accepted"
      end

      it "should add invitee to the inviter team" do
        lambda {
          @invite.accept!
        }.should change(@invite.team.users, :size).by(1)
        @invite.user.team.should == @invite.team
      end
    end

    describe "#decline!" do
      it "should raise an exception if state transition is invalid" do
        @invite.update_attributes(state: 'accepted')
        lambda {
          @invite.decline!
        }.should raise_exception(StateMachine::InvalidTransition)

        @invite.update_attributes(state: 'declined')
        lambda {
          @invite.decline!
        }.should raise_exception(StateMachine::InvalidTransition)
      end

      it "should set invite as declined if it's currently pending" do
        @invite.decline!
        @invite.state.should == "declined"
      end

      it "should not add invitee to the inviter team" do
        lambda {
          @invite.decline!
        }.should_not change(@invite.team.users, :size).by(1)
      end
    end
  end
end
