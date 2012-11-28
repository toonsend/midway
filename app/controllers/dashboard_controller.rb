require 'redcarpet'
class DashboardController < ApplicationController

  def index
  end

  def api
    @api_key = current_user.get_api_key
    @team_id = current_user.id
    readme   = File.open('README.md')
    template = ERB.new(readme.read).result(binding)
    options  = [:hard_wrap, :filter_html, :autolink, :no_intraemphasis, :fenced_code, :gh_blockcode]
    @rc      = Redcarpet.new(template, *options).to_html
  end

  def key
    @user_id = current_user.id
    @key     = current_user.get_api_key
  end

end
