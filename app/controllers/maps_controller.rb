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
      render :json => {"error_code" => map.grid_error}, :status => 422
    end
  rescue JSON::ParserError => e
    render :json => {"error_code" => 'BADLY_FORMED_REQUEST'}, :status => 422
  end

end
