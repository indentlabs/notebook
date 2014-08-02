FactoryGirl.define do
  factory :user do
    sequence(:name) {|n| "testuser#{n}" }
    sequence(:email) {|n| "testemail#{n}" }
    password "userpassword"
  end
  
  factory :universe do
    name "Test universe"
  end

  factory :character do
    name "MyString"
    age "MyString"
  end

  factory :session do
    username "MyString"
    password "MyString"
  end


end
