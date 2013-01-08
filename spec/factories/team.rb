FactoryGirl.define do
  sequence(:name) {|n| "team#{n}" }

  factory :team do
    name
  end
end
