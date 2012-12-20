class TeamsController < ApplicationController

  def create
    current_user.create_team(params[:team])
    current_user.save
    redirect_to :controller => :dashboard, :action => 'key'
  end

end
