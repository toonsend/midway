FactoryGirl.define do

  factory :invite do
    association :team, factory: :team
    association :user, factory: :user
  end
end
