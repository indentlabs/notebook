class Referral < ApplicationRecord
  belongs_to :referrer, class_name: User.name
  belongs_to :referree, class_name: User.name, foreign_key: 'referred_id'
end
