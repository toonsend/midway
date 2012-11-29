require 'spec_helper'

describe Game do

  it "should have a map"
  it "should have a user"
  it "should record the moves in json"

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

  describe "moves" do

    it "should return a hit if the move hits a boat"
    it "should return a hit_and_destroyed if the move hits a boat and destroys it"
    it "should return a miss if the move fails to hit a boat"
    it "should return a miss if the move falls outside the board"
  end



  describe "game ending" do

    it "should end the game if there have been 100 moves"
    it "should end the game if all the ships have been sunk"
    it "should end the game and increase the moves to 100 after failed_to_complete action"

  end


end
