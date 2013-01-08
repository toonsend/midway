require 'validators/map_validator'

class Map < ActiveRecord::Base

  attr_accessible :grid, :team_id
  validates_presence_of :grid, :team_id
  validates_with MapValidator

  serialize :grid, JSON

  GRID_WIDTH = 10
  GRID_HEIGHT = 10

  def game_grid
    @game_grid ||= fill_game_grid
  end

  def ships
    return [] if self.grid.nil?
    self.grid.map do |ship|
      Ship.new(ship)
    end
  end

  def grid_error
    errors[:grid][0]
  end

  private

  def fill_game_grid
    game_grid = empty_game_grid
    self.ships.each do |ship|
      ship.coordinates(GRID_WIDTH, GRID_HEIGHT).each do |x,y|
        raise(MapValidator::ShipOverlapException.new) if (game_grid[x][y] == 'x')
        game_grid[x][y] = 'x'
      end
    end
    game_grid
  end

  def empty_game_grid
    game_grid = []
    GRID_WIDTH.times do |x|
      game_grid[x] = []
      GRID_HEIGHT.times do |y|
        game_grid[x][y] = 'o'
      end
    end
    game_grid
  end

end
