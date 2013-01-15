class GameController < ApplicationController
  skip_before_filter :authenticate_user!

  before_filter :load_api

  def create
    #TODO: move render outside of tx block
    Game.transaction do
      game = Game.where(:id => @team.id).lock(true).first
      if game.nil?
        game = Game.create({:team_id => @team.id}, :without_protection => true)
      end

      if game.valid?
        success, result = game.play(params[:move])

        if success
          render :json => result, :status => 200
        else
          render :json => { "error_code" => result[:error_code], "message" => error_message(result[:error_code]) }, :status => 422
        end
      else
        render :json => error_response(game.errors), :status => 422
      end
    end
  end

  def error_response(errors)
    if errors.include?(:map_id)
      { "error_code" => "NO_GAME", "message" => error_message('NO_GAME') }
    elsif errors.include?(:team_id)
      { "error_code" => "NO_MAPS_UPLOADED", "message" => error_message('NO_MAPS_UPLOADED') }
    else
      { "error_code" => "BADLY_FORMED_REQUEST", "message" => error_message('BADLY_FORMED_REQUEST') }
    end
  end

  def error_message(error)
    message = {
      'OUT_OF_RANGE'         => 'Move is outside of map',
      'NO_GAME'              => 'There is currently no game to play',
      'NO_MAPS_UPLOADED'     => 'Your team does not have any maps so can not enter tournament',
      'INVALID_MOVE'         => 'Invalid move',
      'BADLY_FORMED_REQUEST' => 'Request is invalid'
    }[error]
    message || "Unknown error"
  end
end
