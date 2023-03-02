class CreateBasilFieldGuidances < ActiveRecord::Migration[6.1]
  def change
    create_table :basil_field_guidances do |t|
      t.references :entity, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true
      t.json :guidance

      t.timestamps
    end
  end
end
