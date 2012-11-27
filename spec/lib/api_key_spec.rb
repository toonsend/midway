require 'spec_helper'

describe ApiKey do

  it "is can generate a key" do
    user = FactoryGirl.build(:user, :id => 13)
    Timecop.freeze(Time.local(1985, 1, 31, 22, 15, 0)) do
      ApiKey.generate(user).should == "df51cad4da94f3f5d60c2fdfa038a9fd6133bcad"  
    end
  end

end
