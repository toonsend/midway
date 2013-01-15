class TournamentsController < ApplicationController

  def index
    @tournaments = Tournament.all
  end

  def create
    tournament = Tournament.new(params[:tournament])
    if tournament.save
      redirect_to :action => :index
    else
      flash[:error] = tournament.errors.map {|key, message| "#{key.to_s.humanize} #{message}" }
      redirect_to :action => :index
    end

  end

end
