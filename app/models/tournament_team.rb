class TournamentTeam < ActiveRecord::Base
  attr_accessible :team_id, :tournament_id

  belongs_to :tournament
  belongs_to :team

  scope :active_tournament, lambda { |team_id|
    includes(:team, :tournament).where(["team_id = ? and tournaments.state != 'complete'", team_id])
  }

end
