class TournamentsController < ApplicationController

  before_filter :check_admin?, :except => [:index, :show, :join_tournament]
  before_filter :get_team

  def index
    @tournaments = Tournament.all
  end

  def show
    @tournament = Tournament.find(params[:id])
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

  def forfeit_tournament
    tournament = Tournament.find(params[:id])
    tournament.leave_tournament(@team)
    flash[:error] = "Team removed from tournament #{@team.name}"
    redirect_to :action => :index
  end

  def join_tournament
    tournament = Tournament.find(params[:id])
    tournament.enter_tournament(@team)
    if tournament.save
      flash[:info] = "Team added to tournament #{@team.name}"
      redirect_to tournament
    else
      flash[:error] = "Team not added to tournament #{@team.name}"
      redirect_to :action => :index
    end
  rescue Exception => e
    flash[:error] = e.message
    redirect_to :action => :index
  end

  def start_tournament
    @tournament = Tournament.find(params[:id])
    @tournament.start_tournament!
    redirect_to @tournament
  end

  def end_tournament
    @tournament = Tournament.find(params[:id])
    @tournament.end_tournament!
    redirect_to @tournament
  end

  def get_team
    @team = current_user.team
  end

end
