class AddUserToPageCategory < ActiveRecord::Migration
  def change
    add_reference :page_categories, :user, index: true, foreign_key: true
  end
end
