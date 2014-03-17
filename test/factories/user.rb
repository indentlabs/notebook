FactoryGirl.define do
  sequence :name do |n|
    "testuser#{n}"
  end
  
  sequence :email do |n|
    "test#{n}@example.com"
  end

  factory :user do
    name
    email
    password "MyString"
  end
end
