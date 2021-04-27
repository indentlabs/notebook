class CountryBorderingCountry < ApplicationRecord
  include HasContentLinking
  LINK_TYPE = :two_way

  belongs_to :country
  belongs_to :bordering_country, class_name: Country.name, optional: true
  belongs_to :user, optional: true

  # after_create do
  #   self.reciprocate(
  #     relation:          :country_bordering_countries, 
  #     parent_object_ref: :country, 
  #     added_object_ref:  :bordering_country
  #   )
  # end

  # after_destroy do
  #   # This is a two-way relation, so we should also delete the reverse association
  #   this_object  = Country.find_by(id: self.country_id)
  #   other_object = Country.find_by(id: self.bordering_country_id)

  #   other_object.bordering_countries.delete(this_object) if other_object.present?
  # end
end
