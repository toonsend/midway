# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  api_key                :string(255)
#  team_id                :integer
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

require 'spec_helper'

describe User do

  it "is valid from factory" do
    FactoryGirl.build(:user).should be_a(User)
    FactoryGirl.build(:user).should be_valid
  end

  it "generates api key" do
    user = FactoryGirl.create(:user, :id => 6667)
    lambda do
      user.api_key.should be_nil
      user.generate_api_key!
      user.reload
      user.api_key.should_not be_empty
    end.should_not change(User, :count)
  end

  it "returns key when using #get_api_key" do
    user = FactoryGirl.create(:user, :id => 4454)
    user.get_api_key.should be_a(String)
    user.get_api_key.should_not == true
  end

end
