require 'redcarpet'
class DashboardController < ApplicationController

  def index
  end

  def api
    if current_user.team
      @api_key = current_user.team.get_api_key
      @team_id = current_user.team.id
    else
      @api_key = "<API_KEY>"
      @team_id = ":team_id"
    end
    readme   = File.open('README.md')
    template = ERB.new(readme.read).result(binding)
    options  = [:hard_wrap, :filter_html, :autolink, :no_intraemphasis, :fenced_code, :gh_blockcode]
    @rc      = Redcarpet.new(template, *options).to_html
  end

  def key
    if current_user.team
      @team = current_user.team
      @invite = current_user.team.invites.build(params[:invite])
      @users = current_user.team.users_to_invite(current_user)
    else
      @team = Team.new
    end
  end

end
