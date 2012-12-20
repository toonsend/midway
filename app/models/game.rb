require 'validators/game_validator'

class Game < ActiveRecord::Base
  belongs_to :team
  belongs_to :map

  attr_accessible :map_id, :moves, :state, :user_id
  serialize :moves, Array

  validates_presence_of :user_id, :map_id
  validates_with GameValidator

  before_validation :set_game_defaults, :on => :create

  def play(move)
    self.moves << move
    if self.save
      last_shot, shot_grid = run_moves
      [true, move_state(last_shot, shot_grid)]
    else
      #TODO error handling
      [false, {:error_code => self.errors.first[1]}]
    end
  end

  def map
    @map ||= Map.find_by_id(self.map_id)
  end

  private

  def set_game_defaults
    map_ids = Map.where(["team_id != ?", self.user_id]).map(&:id)
    #TODO define how we want to select the map
    self.map_id = map_ids.at(rand(map_ids.size-1))
    self.state = "playing"
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
      "opponent_id" => self.map.team_id,
      "status"      => shot,
      "move"        => moves.last,
      "game_status" => self.state,
      "moves"       => moves.size
    }
  end
end
