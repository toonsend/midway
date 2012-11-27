require 'spec_helper'

describe User do

  it "is valid from factory" do
    FactoryGirl.build(:user).should be_a(User)
    FactoryGirl.build(:user).should be_valid
  end

end
