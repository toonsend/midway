require 'validators/map_validator'

class Map < ActiveRecord::Base

  attr_accessible :grid, :team_id
  validates_presence_of :grid, :team_id
  validates_with MapValidator

  serialize :grid, JSON

  def game_grid
    @game_grid ||= fill_game_grid
  end

  def ships
    return [] if self.grid.nil?
    self.grid.map do |ship|
      Ship.new(ship)
    end
  end

  private

  def fill_game_grid
    game_grid = empty_game_grid
    self.ships.each do |ship|
      ship.coordinates.each do |x,y|
        raise(MapValidator::ShipOverlapException.new) if (game_grid[x][y] == 'x')
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

end
