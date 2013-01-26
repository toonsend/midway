class LeagueTeam

  attr_accessor :team
  attr_accessor :total_moves
  attr_accessor :games_played
  delegate      :name, :to => :team

  def initialize(team)
    self.team         = team
    self.total_moves  = 0
    self.games_played = 0
  end

  def avg_moves_per_game
    return 0 if self.games_played == 0
    avg_moves = self.total_moves.to_f / self.games_played
    '%.3f' % avg_moves
  end

  def to_hash(league_team)
    {
      :team               => self.team,
      :total_moves        => self.total_moves,
      :games_played       => self.games_played,
      :avg_moves_per_game => avg_moves_per_game
    }
  end

end

