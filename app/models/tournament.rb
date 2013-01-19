# == Schema Information
#
# Table name: tournaments
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  state         :string(255)
#  current_round :integer          default(0)
#  max_rounds    :integer
#  start_at      :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Tournament < ActiveRecord::Base

  attr_accessible :start_at, :state, :max_rounds, :current_round, :name

  validates_presence_of   :start_at
  validates_presence_of   :state
  validates_presence_of   :max_rounds
  validates_presence_of   :name
  validates_uniqueness_of :name

  has_many :games
  has_many :tournament_teams
  has_many :teams, :through => :tournament_teams

  state_machine :state, :initial => :open_to_entry do

    state :open_to_entry,        :in_progress
    state :in_progress, :complete
    state :complete

    after_transition :on => :start_tournament, :do => :create_games
    after_transition :on => :end_tournament,   :do => :end_in_progress_games

    event :start_tournament do
      transition :open_to_entry => :in_progress, :if => lambda { |tourney| tourney.teams.size > 1 }
    end

    event :end_tournament do
      transition :in_progress => :complete
    end

  end

  def self.get_game(team)
    tournament = TournamentTeam.in_progress_tournament(team)
    raise NoTournamentException.new if tournament.nil?
    game = tournament.games.where(:team_id => team.id, :state => 'in_progress').first
    unless game
      game = tournament.games.where(:team_id => team.id, :state => 'pending').first
      game.start_game! if game
    end
    game.nil? ? NoGameException.new : game
  end

  def enter_tournament(team)
    unless TournamentTeam.active_tournament(team).nil?
      raise ExistingTournamentEnteredException.new
    end
    if team.maps.size == 0
      raise NoMapsUploadedException.new
    end
    if in_progress? || complete?
      raise TournamentEntryClosedException.new
    end
    self.teams << team
  end

  def team_can_join?(team)

  end

  private

  def competitors_of(team)
    self.teams.where(["teams.id != ?", team.id])
  end

  def create_games
    generate_round_of_games(self.max_rounds)
  end

  def generate_round_of_games(round)
    self.teams.each do |team|
      create_games_against(team, round)
    end
    generate_round_of_games(round - 1) if round > 1
  end

  def create_games_against(team, round)
    competitors_of(team).each do |competitor|
      Game.create!({
        :team       => team,
        :map        => competitor.map_for_round(round),
        :tournament => self
      })
    end
  end

  def end_in_progress_games
    self.games.non_complete.each do |game|
      game.forfeit_game!
    end
  end

end

class NoTournamentException < Exception;end
class NoGameException < Exception;end
class ExistingTournamentEnteredException < Exception;end
class TournamentEntryClosedException < Exception;end
class NoMapsUploadedException < Exception;end

