class InvitesController < ApplicationController

  def create
    team = Team.find_by_id(params[:team_id])
    if team
      if current_user.team
        if current_user.team == team
          @invite = team.invites.create(params[:invite])
        else
          flash[:error] = "You don't belong to this team"
        end
      else
        flash[:error] = "You don't belong to a team"
      end
    else
      flash[:error] = "Team not found"
    end
    redirect_to teams_path
  end

  def update
    invite = current_user.invites.find_by_id(params[:id])
    if invite
      case params[:commit].to_s.downcase
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
    redirect_to teams_path
  end

  def leave
    current_user.update_attribute(:team, nil)
    redirect_to teams_path
  end

end
