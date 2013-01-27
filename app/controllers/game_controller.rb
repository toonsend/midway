class GameController < ApplicationController

  skip_before_filter :authenticate_user!
  before_filter      :load_api

  def create
    @game = get_game
    success, result = @game.play(params[:move])
    if success
      render :json => result, :status => 200
    else
      render :json => { "error_code" => result[:error_code], "message" => error_message(result[:error_code]) }, :status => 422
    end
  rescue NoTournamentException => e
    render :json => { "error_code" => 'NO_TOURNAMENT', "message" => 'Your team is not in any tournament' }, :status => 422
  rescue NoGameException => e
    render :json => { "error_code" => 'NO_GAME', "message" => 'There is currently no game to play' }, :status => 422
  end

  private

  def get_game
    if params[:test].blank?
      @game = Tournament.get_game(@team)
    else
      @game = Game.get_practice_game(@team)
    end
  end

  def error_message(error)
    message = {
      'OUT_OF_RANGE'         => 'Move is outside of map',
      'INVALID_MOVE'         => 'Invalid move',
      'BADLY_FORMED_REQUEST' => 'Request is invalid'
    }[error]
    message || "Unknown error"
  end
end
