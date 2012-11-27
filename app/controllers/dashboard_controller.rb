class DashboardController < ApplicationController

  def index
  end

  def api
  end

  def key
    @key = current_user.get_api_key
  end

end
