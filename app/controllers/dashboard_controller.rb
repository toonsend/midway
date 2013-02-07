
class DashboardController < ApplicationController

  skip_before_filter :authenticate_user!, :except => :key
  before_filter      :initialize_user_data

  def index
  end

  def api
    @hostname = get_hostname
    readme   = File.open('README.md')
    template = ERB.new(readme.read).result(binding)
    options  = [:hard_wrap, :autolink, :no_intraemphasis, :fenced_code, :gh_blockcode]
    @rc      = Redcarpet.new(template, *options).to_html
  end

  def faq
  end

  def key
    if current_user.team
      @team = current_user.team
    else
      @team = Team.new
    end
  end

  private

  def initialize_user_data
    if current_user
      @api_key = current_user.get_api_key
    else
      @api_key = ':API_KEY'
    end
    if current_user && current_user.team
      @team_id = current_user.team.id
    else
      @team_id = ":team_id"
    end
  end

  def get_hostname
    request.raw_host_with_port
  end

end
