class Map < ActiveRecord::Base

  attr_accessible :grid, :team_id
  validates_presence_of :grid, :team_id

  serialize :grid, JSON

  validate :validate_fleet_size
  validate :validate_ship_sizes
  validate :validate_ship_positions

  VALID_FLEET = [5,4,3,3,2].sort

  def validate_fleet_size
    if self.grid && self.grid.length < 5
      errors.add(:grid, "NOT_ENOUGH_SHIPS")
    elsif self.grid && self.grid.length > 5
      errors.add(:grid, "TOO_MANY_SHIPS")
    end
  end

  def validate_ship_sizes
    if self.ships.map(&:length).sort != VALID_FLEET
      errors.add(:grid, "WRONG_SHIP_SIZE")
    end
  end

  def validate_ship_positions
    game_grid = empty_game_grid
    self.ships.each do |ship|
      ship.coordinates.each do |x,y|
        raise(ShipOverlapException.new) if (game_grid[x][y] == 'x')
        game_grid[x][y] = 'x'
      end
    end
    game_grid
  rescue ShipOutOfBoundsException
    errors.add(:grid, "SHIP_OUT_OF_BOUNDS")
  rescue ShipOverlapException
    errors.add(:grid, "SHIPS_OVERLAP")
  end

  def fill_game_grid
    game_grid = empty_game_grid
    self.ships.each do |ship|
      ship.coordinates.each do |x,y|
        game_grid[x][y] = 'x'
      end
    end
    game_grid
  end

  def empty_game_grid
    game_grid = []
    10.times do |x|
      game_grid[x] = []
      10.times do |y|
        game_grid[x][y] = 'o'
      end
    end
    game_grid
  end

  def ships
    return [] if self.grid.nil?
    self.grid.map do |ship|
      Ship.new(ship)
    end
  end

  def print_game_grid
    puts "GAME GRID"
    puts "____________________"
    game_grid = fill_game_grid
    10.times do |x|
      10.times do |y|
        print game_grid[x][y] + '|'
      end
      puts ""
      print "____________________"
      puts ""
    end
  end

  class ShipOverlapException < Exception
  end

  class ShipOutOfBoundsException < Exception
  end

end
