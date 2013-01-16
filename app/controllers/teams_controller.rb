class TeamsController < ApplicationController

  def index
    if current_user.team
      @team = current_user.team
      @invite = current_user.team.invites.build(params[:invite])
      @users = current_user.team.users_to_invite(current_user)
    else
      @team = Team.new
    end
  end

  def create
    current_user.create_team(params[:team])
    current_user.save
    redirect_to :controller => :dashboard, :action => 'key'
  end

end
