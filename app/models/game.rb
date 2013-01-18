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

require 'validators/game_validator'

class Game < ActiveRecord::Base
  belongs_to :team
  belongs_to :map
  belongs_to :tournament

  attr_accessible :moves, :state, :map, :team, :tournament, :total_moves
  serialize :moves, Array

  validates :team_id, :presence => true
  validates :map_id,  :presence => true
  validates_with GameValidator

  scope :non_complete, where("state != 'completed'")

  HIT_MESSAGE = 'hit'
  MISS_MESSAGE = 'miss'
  HIT_AND_DESTROYED_MESSAGE = 'hit and destroyed'

  MAP_HIT_SYMBOL = 'H'
  MAP_MISS_SYMBOL = 'M'

  state_machine :state, :initial => :pending do

    state :pending,     :in_progress
    state :in_progress, :completed
    state :completed

    after_transition :on => :forfeit,  :do => :foreit_game
    after_transition :on => :end,      :do => :set_total_moves

    event :start do
      transition :pending => :in_progress
    end

    event :end do
      transition :in_progress => :completed
    end

    event :forfeit do
      transition :in_progress => :completed
      transition :pending     => :completed
    end

  end

  def play(move)
    x,y = move
    self.moves << [Integer(x), Integer(y)]
    self.save
    fire(ship_mappings, self.map.empty_game_grid, moves.clone)
  rescue
    return [false, {:error_code => "INVALID_MOVE"}]
  end

  private

  def foreit_game
    self.update_attribute(:total_moves, 100)
  end

  def set_total_moves
    self.update_attribute(:total_moves, moves.size)
  end

  def ship_mappings
    ships = self.map.ships.collect do |ship|
      ship.coordinates(Map::GRID_WIDTH,Map::GRID_HEIGHT)
    end
  end

  def fire(ships, shot_grid, shots)
    shot = shots.shift
    last_shot = MISS_MESSAGE
    update_shot_grid_with_miss(shot_grid, shot)

    ships.each_with_index do |ship, index|
      if ships[index].delete(shot)
        last_shot =  ships[index].empty? ? HIT_AND_DESTROYED_MESSAGE : HIT_MESSAGE
        update_shot_grid_with_hit(shot_grid, shot)
        break
      end
    end

    if shots.empty?
      check_for_end_of_game(ships)
      return [true, move_state(last_shot, shot_grid)]
    end

    return fire(ships, shot_grid, shots)
  end

  def update_shot_grid_with_hit(shot_grid, shot)
    shot_grid[shot[0]][shot[1]] = MAP_HIT_SYMBOL
  end

  def update_shot_grid_with_miss(shot_grid, shot)
    if shot_grid[shot[0]][shot[1]] !=  MAP_HIT_SYMBOL
      shot_grid[shot[0]][shot[1]] = MAP_MISS_SYMBOL
    end
  end

  def check_for_end_of_game(ships)
    end_game_if_fleet_sunk(ships)
    end_game_if_max_moves
  end

  def end_game_if_fleet_sunk(ships)
    ships.each do |ship|
      return false unless ship.empty?
    end
    self.end!
  end

  def end_game_if_max_moves
    if self.moves.size > 99 && self.in_progress?
      self.end!
    end
  end

  def move_state(shot,shot_grid)
    {
      "game_id"     => self.id,
      "grid"        => shot_grid,
      "opponent_id" => self.map.team.id,
      "status"      => shot,
      "move"        => moves.last,
      "game_status" => self.state,
      "moves"       => moves.size
    }
  end
end
