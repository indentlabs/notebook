FactoryGirl.define do
  factory :user do
    sequence :email do |n|
      "user#{n}@example.com"
    end
    password 'password'
  end
  
  factory :universe do
    sequence :name do |n|
      "Universe #{n}"
    end
  end
  
  factory :character do
    sequence :name do |n|
      "Character #{n}"
    end
    user
    universe
  end
  
  factory :location do
    sequence :name do |n|
      "Location #{n}"
    end
    user
    universe
  end
end