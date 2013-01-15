class Invite < ActiveRecord::Base
  attr_accessible :inviter, :invitee, :state

  belongs_to :team, :foreign_key => "inviter"
  belongs_to :user, :foreign_key => "invitee"

  validates :inviter, :presence => true
  validates :invitee, :presence => true
  validates :invitee, :uniqueness => {:scope => :inviter}

  state_machine :state, :initial => :pending do
    state :pending, :accepted, :declined

    event :accept do
      transition :pending => :accepted, :unless => :user_already_has_team?
    end
    after_transition :on => :accept, :do => :add_user_to_team

    event :decline do
      transition :pending => :declined
    end
  end

  private

  def user_already_has_team?
    user.team
  end

  def add_user_to_team
    team.users << user
  end
end
