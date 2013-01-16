class TeamsController < ApplicationController

  def create
    begin
      team = current_user.create_team(params[:team])
      team.users << current_user
      team.save
      current_user.save
      flash[:notice] = "Team created! Yay!"
    rescue
      flash[:alert] = "Error while creating team"
    end
    redirect_to :controller => :dashboard, :action => 'key'          
  end

end
