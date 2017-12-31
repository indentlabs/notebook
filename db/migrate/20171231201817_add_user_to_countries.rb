class AddUserToCountries < ActiveRecord::Migration
  def change
    add_reference :countries, :user, index: true, foreign_key: true
  end
end
