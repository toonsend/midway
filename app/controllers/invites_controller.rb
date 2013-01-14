class InvitesController < ApplicationController

  def create
    if current_user.team
      @invite = current_user.team.invites.create(params[:invite])
    else
      flash[:error] = "You don't own a team to be able to send invites"
    end
    redirect_to :controller => :dashboard, :action => 'key'
  end
end
