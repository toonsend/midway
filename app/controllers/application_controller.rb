class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!

  def load_api
    api_key = request.env['HTTP_MIDWAY_API_KEY'].to_s.strip
    @user = User.find_by_id_and_api_key(params[:team_id], api_key)
    unless @user
      render :json => { "error_code" => "INVALID_API_KEY", "message" => "The api key does not match the team_id" } and return
    end
  end

end

