class Team < ActiveRecord::Base

  attr_accessible :name

  has_many   :users
  has_many   :maps
  has_many   :invites, :foreign_key => "inviter"
  has_one    :game

  validates :name, :presence => true

  def generate_api_key!
    self.api_key = ApiKey.generate(self)
    self.save
  end

  def get_api_key
    self.api_key ||= self.generate_api_key!
  end

  def map_for_round(round)
    maps[round % self.maps.size]
  end

  def users_to_invite(team_owner)
    invited_users = invites.map(&:invitee)
    users = User.where(["users.id != ?", team_owner.id]).reject! {|u| invited_users.include?(u.id) }
    users || []
  end
end
