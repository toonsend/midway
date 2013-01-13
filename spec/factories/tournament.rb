FactoryGirl.define do

  factory :tournament do
    name "tourney 1"
    start_at DateTime.now
    max_rounds 4
  end
end
