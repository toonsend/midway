FactoryGirl.define do

  factory :game do
    team
    association :map, factory: :map
  end
end
