# == Schema Information
#
# Table name: teams
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  api_key    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Team do

  describe "validation" do
    it "should require a name" do
      team = FactoryGirl.build(:team, :name => nil)
      team.should_not be_valid
      team.should have_at_least(1).error_on(:name)
      team.errors[:name].should include("can't be blank")
    end
  end

  describe "#users_to_invite" do
    before(:each) do
      @inviter = FactoryGirl.create(:user, :with_team)
      @team = @inviter.team
    end

    it "should NOT include users that have already been invited" do
      other_user = FactoryGirl.create(:user)
      FactoryGirl.create(:invite, team: @inviter.team, user: other_user)
      invitees = @team.users_to_invite(@inviter)
      invitees.should be_kind_of(Array)
      invitees.should_not include(other_user)
    end

    it "should NOT include users that already have a team" do
      other_user = FactoryGirl.create(:user, :with_team)
      invitees = @team.users_to_invite(@inviter)
      invitees.should be_kind_of(Array)
      invitees.should_not include(other_user)
    end

    it "should NOT include the inviter" do
      invitees = @team.users_to_invite(@inviter)
      invitees.should be_kind_of(Array)
      invitees.should_not include(@inviter)
    end

    it "should return an empty list if there's no users to invite" do
      invitees = @team.users_to_invite(@inviter)
      invitees.should be_kind_of(Array)
      invitees.size.should == 0
    end

    it "should return a list of users to invite" do
      3.times { FactoryGirl.create(:user) }
      invitees = @team.users_to_invite(@inviter)
      invitees.should be_kind_of(Array)
      invitees.size.should == 3
    end

  end
end
