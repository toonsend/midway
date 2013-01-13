class Tournament < ActiveRecord::Base

  attr_accessible :start_at, :state, :max_rounds, :current_round

  validates_presence_of   :start_at
  validates_presence_of   :state
  validates_presence_of   :max_rounds
  validates_presence_of   :name
  validates_uniqueness_of :name

  has_many :games
  has_many :tournament_teams
  has_many :teams, :through => :tournament_teams

  state_machine :state, :initial => :open do

    state :open, :in_progress
    state :in_progress, :complete
    state :complete

    event :start do
      transition :open => :in_progress
    end

    event :end do
      transition :in_progress => :complete
    end

  end

  def enter_tournament(team)
    unless TournamentTeam.active_tournament(team.id).empty?
      raise TournamentAlreadyEnteredException.new
    end
    self.teams << team
  end

end

class TournamentAlreadyEnteredException < Exception;end

