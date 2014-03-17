FactoryGirl.sequence :email do |n|
  "test#{n}@example.com"
end

FactoryGirl.sequence :username do |n|
  "testuser#{n}"
end

FactoryGirl.define :user do |user|
  user.name { FactoryGirl.next(:username) }
  user.email { FactoryGirl.next(:email) }
  user.password "MyString"
end
