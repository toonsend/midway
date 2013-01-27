require 'redcarpet'
class DashboardController < ApplicationController

  def index
  end

  def api
    @api_key = current_user.get_api_key
    @hostname = get_hostname
    if current_user.team
      @team_id = current_user.team.id
    else
      @team_id = ":team_id"
    end
    readme   = File.open('README.md')
    template = ERB.new(readme.read).result(binding)
    options  = [:hard_wrap, :autolink, :no_intraemphasis, :fenced_code, :gh_blockcode]
    @rc      = Redcarpet.new(template, *options).to_html
  end

  def key
    @api_key = current_user.get_api_key
    if current_user.team
      @team = current_user.team
    else
      @team = Team.new
    end
  end

  private

  def get_hostname
    request.raw_host_with_port
  end

end
