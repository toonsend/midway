class MapsController < ApplicationController
  skip_before_filter :authenticate_user!

  before_filter :load_api

  def index
    # TODO: implement me
    render :json => {"error_code" => "BADLY_FORMED_REQUEST"}
  end

  def create
    # TODO: implement me
    render :json => {"error_code" => "BADLY_FORMED_REQUEST"}
  end

end
