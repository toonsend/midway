# == Schema Information
#
# Table name: tournament_teams
#
#  id            :integer          not null, primary key
#  tournament_id :integer
#  team_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class TournamentTeam < ActiveRecord::Base
  attr_accessible :team_id, :tournament_id

  belongs_to :tournament
  belongs_to :team

  def self.active_tournament(team)
    tournament_team = includes(:team, :tournament)
    .where(["team_id = ? and tournaments.state != 'complete'", team.id])
    .first
    tournament_team.nil? ? nil : tournament_team.tournament
  end

  def self.in_progress_tournament(team)
    tournament_team = includes(:team, :tournament)
    .where(["team_id = ? and tournaments.state = 'in_progress'", team.id])
    .first
    tournament_team.nil? ? nil : tournament_team.tournament
  end

end
