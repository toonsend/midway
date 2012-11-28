require 'spec_helper'

describe Map do

  def valid_grid
    JSON.parse(valid_grid_params)
  end

  it "is valid from factory" do
    FactoryGirl.build(:map).should be_a(Map)
    FactoryGirl.build(:map).should be_valid
  end

  it "should output the grid as json" do
    map = FactoryGirl.build(:map, :grid => valid_grid)
    map.grid[0].should == [0,0,5,"across"]
  end

  describe "validation" do

    it "should require a grid" do
      map = FactoryGirl.build(:map, :grid => nil)
      map.should_not be_valid
      map.should have_at_least(1).error_on(:grid)
      map.errors[:grid].should include("can't be blank")
    end

    it "should require a team_id" do
      map = FactoryGirl.build(:map, :team_id => nil)
      map.should_not be_valid
      map.should have_at_least(1).error_on(:team_id)
      map.errors[:team_id].should include("can't be blank")
    end

    it "should validate there are enough ships" do
      grid = valid_grid
      grid.delete_at(0)
      map = FactoryGirl.build(:map, :grid => grid)
      map.should_not be_valid
      map.should have_at_least(1).error_on(:grid)
      map.errors[:grid].should include("NOT_ENOUGH_SHIPS")
    end

    it "should validate there are not too many ships" do
      grid = valid_grid << [6, 2, 4, "across"]
      map = FactoryGirl.build(:map, :grid => grid)
      map.should_not be_valid
      map.should have_at_least(1).error_on(:grid)
      map.errors[:grid].should include("TOO_MANY_SHIPS")
    end

    it "should validate sizes of ships" do
      grid = valid_grid
      grid[0] = [0, 0, 4, "down"]
      map = FactoryGirl.build(:map, :grid => grid)
      map.should_not be_valid
      map.should have(1).error_on(:grid)
      map.errors[:grid].should == ["WRONG_SHIP_SIZE"]
    end

    it "should validate if ships are overlapping" do
      grid = valid_grid
      battleship = Ship.new(grid[1])
      grid[0] = [battleship.xpos, battleship.ypos, 5, battleship.direction]
      map = FactoryGirl.build(:map, :grid => grid)
      map.should_not be_valid
      map.should have(1).error_on(:grid)
      map.errors[:grid].should == ["SHIPS_OVERLAP"]
    end

    it "should validate ships are within grid" do
      grid = valid_grid
      grid[0] = [9, 0, 5, 'across']
      map = FactoryGirl.build(:map, :grid => grid)
      map.should_not be_valid
      map.should have(1).error_on(:grid)
      map.errors[:grid].should == ["SHIP_OUT_OF_BOUNDS"]
    end

  end

end
