FactoryBot.define do
  sequence :email do |n|
    "email#{n}@example.com"
  end

  factory :user do
    email
    password { 'password' }
  end

#   factory :universe do
#     sequence :name do |n|
#       "Universe #{n}"
#     end
#     user
#   end

#   factory :character do
#     sequence :name do |n|
#       "Character #{n}"
#     end
#     user
#   end

#   factory :location do
#     sequence :name do |n|
#       "Location #{n}"
#     end
#     user
#   end

#   factory :item do
#     sequence :name do |n|
#       "Item #{n}"
#     end
#     user
#   end

#   factory :attribute_category do
#     sequence :name do |n|
#       "attribute_category_#{n}"
#     end
#     sequence :label do |n|
#       "Attribute Category #{n}"
#     end
#     user
#     entity_type 'character'
#   end

#   factory :attribute_field do
#     sequence :name do |n|
#       "attribute_category_#{n}"
#     end
#     sequence :label do |n|
#       "Attribute Category #{n}"
#     end
#     user
#     attribute_category
#     field_type 'textarea'
#   end
end
