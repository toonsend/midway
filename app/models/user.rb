class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body

	belongs_to :team
	has_many :invites, :foreign_key => "invitee"

  def generate_api_key!
    self.api_key = ApiKey.generate(self)
    self.save
    self.api_key
  end

  def get_api_key
    self.api_key ||= self.generate_api_key!
  end

end
