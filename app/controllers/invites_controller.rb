class InvitesController < ApplicationController

  def create
    @invite = current_user.team.invites.create(params[:invite])
    redirect_to :controller => :dashboard, :action => 'key'
  end
end
