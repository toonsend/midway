class Team < ActiveRecord::Base
  has_many :users
  has_many :maps
  has_many :invites, :foreign_key => "inviter"
  has_one  :game

  attr_accessible :name

  validates :name, :presence => true

  def users_to_invite(inviter)
    invited_users = invites.map(&:invitee)
    User.where(["id != ? and team_id is null", inviter.id]).reject {|u| invited_users.include?(u.id) }
  end
end
