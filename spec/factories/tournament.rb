FactoryGirl.define do

  factory :tournament do
    sequence(:name) {|n| "tournament_#{n}" }
    start_at DateTime.now
    max_rounds 4
  end

end
