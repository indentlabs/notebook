FactoryGirl.define do
  sequence :email do |n|
    "email#{n}@example.com"
  end

  factory :user do
    email
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

  factory :item do
    sequence :name do |n|
      "Item #{n}"
    end
    user
    universe
  end
end
