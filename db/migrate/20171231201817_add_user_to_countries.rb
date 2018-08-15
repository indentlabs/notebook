class AddUserToCountries < ActiveRecord::Migration[4.2]
  def change
    add_reference :countries, :user, index: true, foreign_key: true
  end
end
