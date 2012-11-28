class MapsController < ApplicationController
  skip_before_filter :authenticate_user!

  before_filter :load_api

  def index
    # TODO: implement me
    render :json => {"error_code" => "BADLY_FORMED_REQUEST"}
  end

  def create
    map = Map.new({
      :team_id => params[:team_id],
      :grid    => params[:grid]
    })
    if map.save
      render :json => {"id" => map.id}, :status => 200
    else
      render :json => {"error_code" => map.grid_error, "message" => error_message(map.grid_error)}, :status => 422
    end
  end

  def render_error
    render :json => {"error_code" => 'BADLY_FORMED_REQUEST', "message" => error_message('BADLY_FORMED_REQUEST')}, :status => 422
  end

  def error_message(error)
    {
      'NOT_ENOUGH_SHIPS'     => 'Not enough ships',
      'TOO_MANY_SHIPS'       => 'Too many ships',
      'WRONG_SHIP_SIZE'      => 'Ships are not of the required size',
      'SHIPS_OVERLAP'        => 'Ships in collision',
      'SHIP_OUT_OF_BOUNDS'   => 'Ship is positioned outside of map',
      'BADLY_FORMED_REQUEST' => 'Request is invalid'
    }[error]
  end

end
