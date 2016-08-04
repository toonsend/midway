class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!

  def load_api
    api_key = request.headers['HTTP-MIDWAY-API-KEY'].to_s.strip
    Rails.logger.info("looking for #{params[:team_id]} with api key #{api_key}")
    @user = User.first('team_id = ?', params[:team_id])
    if @user
      if @user.api_key != api_key
        render :json => { "error_code" => "INVALID_API_KEY", "message" => "The api key does not match the team_id" } and return
      end
    else
      render :json => { "error_code" => "TEAM_NOT_FOUND", "message" => "Team not found" }, :status => 404 and return
    end
  end

  def check_admin?
    unless current_user.admin?
      render  :text => "You do not have permission to perform this action"
    end
  end

end

