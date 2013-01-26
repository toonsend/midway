# == Schema Information
#
# Table name: games
#
#  id            :integer          not null, primary key
#  moves         :text
#  state         :string(255)
#  map_id        :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  tournament_id :integer
#  team_id       :integer
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

  end

  describe "states" do

    it "should begin in pending" do
      game = FactoryGirl.create(:game)
      game.pending?.should be_true
    end

    it "should progress from pending to in_progress" do
      game = FactoryGirl.create(:game)
      game.start_game!
      game.in_progress?.should be_true
    end

    it "should progress from in_progress to complete" do
      game = FactoryGirl.create(:game)
      game.start_game!
      game.end_game!
      game.completed?.should be_true
    end

    it "should mark the total moves when game is completed" do
      game = FactoryGirl.create(:game)
      game.start_game!
      game.play([0,0])
      game.play([3,5])
      game.end_game!
      game.total_moves.should == 2
    end

    it "should progress from in_progress to complete with forfeit" do
      game = FactoryGirl.create(:game)
      game.start_game!
      game.forfeit_game!
      game.completed?.should be_true
    end

    it "should progress from pending to complete with forfeit" do
      game = FactoryGirl.create(:game)
      game.forfeit_game!
      game.completed?.should be_true
    end

    it "should mark total moves as 100 after forfeit" do
      game = FactoryGirl.create(:game)
      game.forfeit_game!
      game.total_moves.should == 100
    end

    it "should show all in progress games" do
      game1 = FactoryGirl.create(:game)
      game2 = FactoryGirl.create(:game)
      game2.update_attribute(:state, 'completed')
      game3 = FactoryGirl.create(:game)
      game3.update_attribute(:state, 'in_progress')
      Game.non_complete.should == [game1, game3]
    end

  end

  describe "#play" do

    before(:each) do
      @game = FactoryGirl.create(:game)
      @game.start_game!
    end

    it "should return hit after hit and previously destroyed a boat" do

      @game.play([0,0])
      @game.play([1,0])
      @game.play([2,0])
      @game.play([3,0])
      success, result = @game.play([4,0])

      result['status'].should == "hit and destroyed"

      success, result = @game.play([6,2])
      result['status'].should == "hit"

    end

    it "should return a hit if the move hits a boat" do
      success, result = @game.play([0,0])
      success.should be_true
      result['status'].should == 'hit'
    end

    it "should return a hit if the move hits a boat" do
      @game.map.ships[0].coordinates(10,10).each do |move|
        success, result = @game.play(move)
        success.should be_true
      end
    end

    it "should return a hit_and_destroyed if the move hits a boat and destroys it" do
      coordinates = @game.map.ships[0].coordinates(10,10)
      coordinate = coordinates.pop
      coordinates.each do |move|
        success, result = @game.play(move)
      end
      success, result = @game.play(coordinate)
      success.should be_true
      result['status'].should == 'hit and destroyed'
    end

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

    describe "game ending" do

      it "should end game when all the ships are sunk" do
        moves = 0
        @game.map.ships.each do |ship|
          ship.coordinates(10,10).each do |move|
            success, result = @game.play(move)
            success.should be_true
            moves += 1
          end
        end
        @game.state.should == 'completed'
        @game.total_moves.should == moves
      end

      it "should fill in the grid correctly when sent duplicate moves" do
        success, result = @game.play([0,0])
        result['status'].should == "hit"
        success, result = @game.play([0,0])
        result['status'].should == "miss"
      end

      it "should report duplicate moves as a miss" do
        success, result = @game.play([0,0])
        result['status'].should == "hit"
        success, result = @game.play([0,0])
        result['status'].should == "miss"
      end

      it "should fill in the grid correctly when sent duplicate moves" do
        success, result = @game.play([0,0])
        result['grid'][0][0].should == 'H'
        success, result = @game.play([0,0])
        result['grid'][0][0].should == 'H'
      end


      it "should change the state to complete if moves reach 100" do
        99.times do
          @game.moves << [0,0]
        end
        @game.play([0,0])
        @game.completed?.should be_true
      end
    end

  end

  describe "practice games" do

    before(:each) do
      @team = FactoryGirl.create(:team)
    end

    it "should make games start with practice as false" do
      Game.new.practice.should be_false
    end

    it "should provide a new game if one does not exist" do
      Game.get_practice_game(@team).should be_an_instance_of(Game)
    end

    it "should provide a game in progress if one does not exist" do
      game = Game.get_practice_game(@team)
      game.state.should == 'in_progress'
    end

    it "should provide a game in progress if one does not exist" do
      practice_game = Game.get_practice_game(@team)
      game = Game.get_practice_game(@team)
      game.should == practice_game
    end

  end

end
