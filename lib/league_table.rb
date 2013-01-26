class LeagueTable

  attr_accessor :tournament

  def initialize(tourney)
    self.tournament = tourney
  end

  def each
    sorted_league_teams.each do |league_team|
      yield(league_team)
    end
  end

  def sorted_league_teams
    teams = tournament.teams.map do |team|
      team_league_entry(team)
    end
    teams.sort! do |teama, teamb|
      [teamb.games_played, teama.total_moves] <=> [teama.games_played, teamb.total_moves]
    end
  end

  def team_league_entry(team)
    league_team = LeagueTeam.new(team)
    total_moves = tournament.team_games(team).each do |game|
      league_team.total_moves  += game.total_moves
      league_team.games_played += 1 if game.completed?
    end
    league_team
  end

end
