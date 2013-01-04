FactoryGirl.define do
  sequence(:email) {|n| "battleship.admiral#{n}@killemall.com" }

  factory :user do
    email
    password "password"
    password_confirmation "password"
    team
  end

end
