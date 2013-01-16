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
    begin
      self.moves << [Integer(x), Integer(y)]
    rescue
      return [false, {:error_code => "INVALID_MOVE"}]
    end

    if self.moves.size > 99
      self.end!
    end

    if self.save
      last_shot, shot_grid = run_moves
      [true, move_state(last_shot, shot_grid)]
    else
      puts errors.inspect
      #TODO error handling
      [false, {:error_code => self.errors.first[1]}]
    end
  end

  private

  def foreit_game
    self.update_attribute(:total_moves, 100)
  end

  def set_total_moves
    self.update_attribute(:total_moves, moves.size)
  end

  def run_moves
    shot_grid = self.map.send(:empty_game_grid)
    last_shot = 'none'
    self.moves.each do |x,y|
      if self.map.game_grid[x][y] == 'x'
        shot_grid[x][y] = 'H'
        last_shot = 'hit'
      else
        shot_grid[x][y] = 'M'
        last_shot = 'miss'
      end
    end
    [last_shot, shot_grid]
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
