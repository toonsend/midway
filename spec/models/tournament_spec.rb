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
    tournament = FactoryGirl.build(:tournament)
    tournament.start!
    tournament.state.should == 'in_progress'
  end

  it "should move from in_progress to complete state" do
    tournament = FactoryGirl.build(:tournament)
    tournament.start!
    tournament.end!
    tournament.state.should == 'complete'
  end

  it "should have games" do
    tournament = FactoryGirl.build(:tournament)
    tournament.games << FactoryGirl.build(:game)
    tournament.games.size.should == 1
  end

  it "should have teams" do
    tournament = FactoryGirl.build(:tournament)
    tournament.teams << FactoryGirl.build(:team)
    tournament.teams.size.should == 1
  end

  it "should allow a team to only enter one in progress or open tournament" do
    team       = FactoryGirl.create(:team)
    tournament = FactoryGirl.create(:tournament)
    tournament.enter_tournament(team)
    tournament2 = FactoryGirl.create(:tournament, :name => 'tourney 2')
    expect {
      tournament2.enter_tournament(team)
    }.to raise_error(TournamentAlreadyEnteredException)
  end

  it "should allow a team to enter a tournament when they only have completed tournaments" do
    team       = FactoryGirl.create(:team)
    tournament = FactoryGirl.create(:tournament)
    tournament.enter_tournament(team)
    tournament.update_attribute(:state, 'complete')
    tournament2 = FactoryGirl.create(:tournament, :name => 'tourney 2')
    expect {
      tournament2.enter_tournament(team)
    }.to change(TournamentTeam, :count).by(1)
  end

  it "should not allow teams to enter if they have no maps uploaded"
  it "should not allow teams to enter after the tournament is in progress"

  it "should create tournament games on start" do
  end

  it "should return current game given team_id"
  it "should raise tournament over if there are no more games to play"

  it "should calculate a league table"

end
