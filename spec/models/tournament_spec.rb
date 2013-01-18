# == Schema Information
#
# Table name: tournaments
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  state         :string(255)
#  current_round :integer          default(0)
#  max_rounds    :integer
#  start_at      :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe Tournament do

  it "should create a valid tournament" do
    FactoryGirl.build(:tournament).should be_valid
  end

  it "should require a start date" do
    tournament = FactoryGirl.build(:tournament, :start_at => nil)
    tournament.should_not be_valid
  end

  it "should require a name" do
    tournament = FactoryGirl.build(:tournament, :name => nil)
    tournament.should_not be_valid
    tournament.should have(1).error_on(:name)
  end

  it "should require name to be unique" do
    FactoryGirl.create(:tournament, :name => 'tourney 1').should be_valid
    tournament = FactoryGirl.build(:tournament, :name => 'tourney 1')
    tournament.should_not be_valid
    tournament.should have(1).error_on(:name)
  end

  it "should require a number of rounds" do
    tournament = FactoryGirl.build(:tournament, :max_rounds => nil)
    tournament.should_not be_valid
    tournament.should have(1).error_on(:max_rounds)
  end

  it "should set round as 0 by default" do
    tournament = FactoryGirl.build(:tournament)
    tournament.current_round.should == 0
  end

  it "should start in open state" do
    tournament = FactoryGirl.build(:tournament)
    tournament.state.should == 'open'
  end

  it "should move from open to in_progress state" do
    tournament = valid_tournament
    tournament.start_tournament!
    tournament.state.should == 'in_progress'
  end

  it "should move from in_progress to complete state" do
    tournament = valid_tournament
    tournament.start_tournament!
    tournament.end_tournament!
    tournament.state.should == 'complete'
  end

  it "should have games" do
    tournament = FactoryGirl.build(:tournament)
    tournament.games << FactoryGirl.build(:game)
    tournament.games.size.should == 1
  end

  it "should have teams" do
    tournament = FactoryGirl.build(:tournament)
    tournament.enter_tournament(valid_team)
    tournament.teams.size.should == 1
  end

  it "should allow a team to only enter one in progress or open tournament" do
    team       = valid_team
    tournament = FactoryGirl.create(:tournament)
    tournament.enter_tournament(team)
    tournament2 = FactoryGirl.create(:tournament, :name => 'tourney 2')
    expect {
      tournament2.enter_tournament(team)
    }.to raise_error(ExistingTournamentEnteredException)
  end

  it "should allow a team to enter a tournament when they only have completed tournaments" do
    team       = valid_team
    tournament = FactoryGirl.create(:tournament)
    tournament.enter_tournament(team)
    tournament.update_attribute(:state, 'complete')
    tournament2 = FactoryGirl.create(:tournament, :name => 'tourney 2')
    expect {
      tournament2.enter_tournament(team)
    }.to change(TournamentTeam, :count).by(1)
  end

  it "should not allow teams to enter if they have no maps uploaded" do
    team       = FactoryGirl.create(:team)
    tournament = FactoryGirl.create(:tournament)
    expect {
      tournament.enter_tournament(team)
    }.to raise_error(NoMapsUploadedException)
    team.maps << FactoryGirl.create(:map)
    tournament.enter_tournament(team)
  end

  it "should not allow teams to enter after the tournament is in progress" do
    team       = valid_team
    tournament = FactoryGirl.create(:tournament)
    tournament.update_attribute("state", "in_progress")
    expect {
      tournament.enter_tournament(team)
    }.to raise_error(TournamentEntryClosedException)
  end

  it "should not allow teams to enter after the tournament is in complete" do
    team       = valid_team
    tournament = FactoryGirl.create(:tournament)
    tournament.update_attribute("state", "complete")
    expect {
      tournament.enter_tournament(team)
    }.to raise_error(TournamentEntryClosedException)
  end

  it "should not allow a tournament to start if there are less than 2 teams" do
    team       = valid_team
    tournament = FactoryGirl.create(:tournament)
    expect {
      tournament.start_tournament!
    }.to raise_error(StateMachine::InvalidTransition)

    tournament.teams << valid_team
    expect {
      tournament.start_tournament!
    }.to raise_error(StateMachine::InvalidTransition)

    tournament.teams << valid_team
    tournament.start_tournament!
    tournament.in_progress?.should be_true
  end

  it "should create tournament games on start" do
    tournament = valid_tournament
    expect {
      tournament.start_tournament!
    }.to change(Game, :count).by(tournament.max_rounds * tournament.teams.size)
  end

  it "should create tournament games on start based on max rounds" do
    tournament = valid_tournament
    tournament.teams << valid_team
    tournament.update_attribute(:max_rounds, 2)
    expect {
      tournament.start_tournament!
    }.to change(Game, :count).by(12)
  end

  it "should create tournament games on with correct team id" do
    tournament = valid_tournament
    tournament.teams << valid_team
    tournament.update_attribute(:max_rounds, 2)
    tournament.start_tournament!
    tournament.teams.each do |team|
      Game.where(:team_id => team.id).count.should == 4
    end
  end

  it "should return current game given team_id" do
    tournament = valid_tournament
    team       = valid_team
    tournament.teams << team
    tournament.start_tournament!
    Tournament.get_game(team).should be_an_instance_of(Game)
  end

  it "should end any unfinished game in a tournament" do
    tournament = valid_tournament
    tournament.start_tournament!
    Game.all.each do |game|
      game.completed?.should be_false
    end
    tournament.end_tournament!
    Game.all.each do |game|
      game.completed?.should be_true
    end
  end

  it "should calculate a league table"

end
