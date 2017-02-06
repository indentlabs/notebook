class CreateOfficeships < ActiveRecord::Migration
  def change
    create_table :officeships do |t|
      t.integer :user_id
      t.integer :group_id
      t.integer :office_id
    end
  end
end
