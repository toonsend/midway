class InvitesController < ApplicationController

  def create
    if current_user.team
      @invite = current_user.team.invites.create(params[:invite])
    else
      flash[:error] = "You don't own a team to be able to send invites"
    end
    redirect_to :controller => :dashboard, :action => 'key'
  end

  def update
    invite = current_user.invites.find_by_id(params[:id])
    if invite
      case params[:submit]
      when "accept"
        if current_user.team
          flash[:error] = "You already belong to a team!"
        else
          invite.accept!
        end
      when "decline"
        invite.decline!
      else
        flash[:error] = "You should accept or decline the invite"
      end
    else
      flash[:error] = "Invite not found"
    end
    redirect_to :controller => :dashboard, :action => 'key'
  end
end
