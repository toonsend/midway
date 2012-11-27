class GameController < ApplicationController
  skip_before_filter :authenticate_user!

  before_filter :load_api

  def create
    # TODO: implement me
    render :json => { "error_code" => "OUT_OF_RANGE", "message" => "move is outside of map" }
  end

end
