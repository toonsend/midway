# == Schema Information
#
# Table name: games
#
#  id            :integer          not null, primary key
#  team_id       :integer
#  map_id        :integer
#  moves         :text
#  state         :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  tournament_id :integer
#

require 'spec_helper'

describe Game do

  describe "validation" do

    it "should require a map" do
      game = FactoryGirl.build(:game, :map_id => nil)
      game.should_not be_valid
      game.should have_at_least(1).error_on(:map_id)
      game.errors[:map_id].should include("can't be blank")
    end

    it "should require a team" do
      game = FactoryGirl.build(:game, :team_id => nil)
      game.should_not be_valid
      game.should have_at_least(1).error_on(:team_id)
      game.errors[:team_id].should include("can't be blank")
    end

    it "should validate the moves are correct" do
      game = FactoryGirl.build(:game, :moves => 1)
      game.should_not be_valid
      game.should have(1).error_on(:moves)
      game.errors[:moves].should == ["INVALID_MOVE"]
    end

    it "should validate the user has uploaded some maps" do
      game = FactoryGirl.build(:game)
      game.should_not be_valid
      game.should have(1).error_on(:team_id)
      game.errors[:team_id].should == ["NO_MAPS_UPLOADED"]
    end
  end

  describe "test game" do

    it "should return a new a test game if one doesn't exist"
    it "should return the existing test game if one exists in progress"

  end

  describe "states" do

    it "should begin in pending"
    it "should progress from pending to in_progress"
    it "should progress from in_progress to complete"
    it "should render the current game map as a 10 element array"

  end

  describe "#play" do
    before(:each) do
      @team = FactoryGirl.create(:team)
      @opponent = FactoryGirl.create(:team)
      @map = FactoryGirl.create(:map, :team => @team)
      @opponent_map = FactoryGirl.create(:map, :team => @opponent)
      @game = FactoryGirl.create(:game, :team => @team)
    end

    it "should return a hit if the move hits a boat" do
      success, result = @game.play([0,0])
      success.should be_true
      result['status'].should == 'hit'
    end

    it "should return a hit_and_destroyed if the move hits a boat and destroys it"

    it "should return a miss if the move fails to hit a boat" do
      success, result = @game.play([0,1])
      success.should be_true
      result['status'].should == 'miss'
    end

    it "should return a miss if the move falls outside the board" do
      success, result = @game.play([0,11])
      success.should be_true
      result['status'].should == 'miss'
    end
  end

  describe "game ending" do

    it "should end the game if there have been 100 moves"
    it "should end the game if all the ships have been sunk"
    it "should end the game and increase the moves to 100 after failed_to_complete action"

  end


end
