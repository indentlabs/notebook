FactoryGirl.define do
  factory :user do
    sequence(:name) {|n| "testuser#{n}" }
    sequence(:email) {|n| "test#{n}@example.com" }
    password "MyString"
  end
end
