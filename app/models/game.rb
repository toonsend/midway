require 'validators/game_validator'

class Game < ActiveRecord::Base
  belongs_to :team
  belongs_to :map

  attr_accessible :moves, :state
  serialize :moves, Array

  validates :team_id, :presence => true
  validates :map_id,  :presence => true
  validates_with GameValidator

  before_validation :set_game_defaults, :on => :create

  def play(move)
    x,y = move
    begin
      self.moves << [Integer(x), Integer(y)]
    rescue
      return [false, {:error_code => "INVALID_MOVE"}]
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

  def set_game_defaults
    return if !team
    maps = Map.all - team.maps
    #TODO define how we want to select the map
    self.map = maps[rand(maps.length)]
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
      "opponent_id" => self.map.team.id,
      "status"      => shot,
      "move"        => moves.last,
      "game_status" => self.state,
      "moves"       => moves.size
    }
  end
end
