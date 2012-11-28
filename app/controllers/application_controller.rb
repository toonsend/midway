class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!

  def load_api
    api_key = request.headers['HTTP_MIDWAY_API_KEY'].to_s.strip
    Rails.logger.info("looking for #{params[:team_id]} with api key #{api_key}")
    @user = User.find_by_id_and_api_key(params[:team_id], api_key)
    unless @user
      render :json => { "error_code" => "INVALID_API_KEY", "message" => "The api key does not match the team_id" } and return
    end
  end

end

