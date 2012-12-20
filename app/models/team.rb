class Team < ActiveRecord::Base
  has_many :users
  has_many :maps
  has_many :invites, :foreign_key => "inviter"

  attr_accessible :name

  validates :name, :presence => true

  def generate_api_key!
    self.api_key = ApiKey.generate(self)
    self.save
  end

  def get_api_key
    self.api_key ||= self.generate_api_key!
  end

  def users_to_invite(team_owner)
    invited_users = invites.map(&:invitee)
    User.where(["users.id != ?", team_owner.id]).reject! {|u| invited_users.include?(u.id) }
  end
end
