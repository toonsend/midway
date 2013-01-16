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

require 'spec_helper'

describe TournamentTeam do
  pending "adds some specs for active_tournament scope"
  pending "adds some specs for in_progress_tournament scope"
end
