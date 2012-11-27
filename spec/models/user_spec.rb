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

end
