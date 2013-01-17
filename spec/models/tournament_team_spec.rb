# == Schema Information
#
# Table name: tournament_teams
#
#  id            :integer          not null, primary key
#  tournament_id :integer
#  team_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe TournamentTeam do

  before(:each) do
    @tournament = FactoryGirl.create(:tournament)
    @team       = FactoryGirl.create(:team)
    @tournament.teams << @team
    @tournament.teams << FactoryGirl.create(:team)
    @tournament.save
  end

  it "should return the correct tournaments for active_tournament scope" do
    TournamentTeam.active_tournament(@team).should == @tournament
    @tournament.update_attribute(:state, 'pending')
    TournamentTeam.active_tournament(@team).should == @tournament
    @tournament.update_attribute(:state, 'complete')
    TournamentTeam.active_tournament(@team).should be_nil
  end

  it "should return the correct tournaments for in_progress_tournament scope" do
    TournamentTeam.in_progress_tournament(@team).should be_nil
    @tournament.update_attribute(:state, 'in_progress')
    TournamentTeam.in_progress_tournament(@team).should == @tournament
    @tournament.update_attribute(:state, 'complete')
    TournamentTeam.in_progress_tournament(@team).should be_nil
  end

end
