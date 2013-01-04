FactoryGirl.define do

  factory :map do
    team
    grid JSON.parse('[[0, 0, 5, "across"], [6, 2, 4, "across"], [3, 6, 3, "down"], [7, 8, 3, "across"], [4, 6, 2, "across"]]')
  end

end
