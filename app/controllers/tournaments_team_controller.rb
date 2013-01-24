class TournamentsTeamsController < ApplicationController

  def create
    @tournament_team = TournamentTeam.new({
      :tournament_id => params[:tournament_team_id],
      :team_id       => params[:team_id]
    })
    if @tournament_team.save
      flash[:info] = "Team added to tournament #{@tournament_team.name}"
    else
      flash[:error] = "Team not added to tournament #{@tournament_team.name}"
    end
    redirect_to tournaments_path
  end

end
