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
    game = tournament.get_current_game(team)
    game.nil? ? raise(NoGameException.new) : game
  end

  def get_current_game(team)
    game = self.games_for(team).where(:state => 'in_progress').first
    unless game
      game = self.games_for(team).where(:state => 'pending').first
      game.start_game! if game
    end
    game
  end

  def games_for(team)
    games.where(:team_id => team.id)
  end

  def enter_tournament(team)
    if team_can_join?(team)
      self.teams << team
    end
  end

  def team_can_join?(team)
    unless TournamentTeam.active_tournament(team).nil?
      raise ExistingTournamentEnteredException.new("Team is already in a tournament")
    end
    if team.maps.size == 0
      # here we will generate 3 random maps for slackaz who did not want to prepare it!
      1.upto(3) {  Map.get_random_map(team) }
      #raise NoMapsUploadedException.new("A team with no maps can't enter a tournament")
    end
    unless open_to_entry?
      raise TournamentEntryClosedException.new("Tournament is closed to entries")
    end
    return true
  end

  def leave_tournament(team)
    if in_progress?
      team_forfeit(team)
    end
    self.teams.delete(team)
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

  def team_forfeit(team)
    self.games.where(:team_id => team.id).each do |game|
      game.forfeit_game!
    end
  end

end

class TournamentException < Exception;end
class NoTournamentException < TournamentException;end
class NoGameException < TournamentException;end
class ExistingTournamentEnteredException < TournamentException;end
class TournamentEntryClosedException < TournamentException;end
class NoMapsUploadedException < TournamentException;end

