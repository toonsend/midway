# == Schema Information
#
# Table name: maps
#
#  id         :integer          not null, primary key
#  grid       :text
#  team_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'validators/map_validator'

class Map < ActiveRecord::Base
  belongs_to :team
  has_one :game

  attr_accessible :grid, :team_id
  validates :grid, :presence => true
  validates :team_id, :presence => true
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

  def to_s
    str = game_grid.map do |row|
      row.map { |position| position == 'x' ? "\e[31m#{position}\e[0m" : position }.join(" | ")
    end
    puts str.join("\n")
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
