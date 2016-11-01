class CreateAttributes < ActiveRecord::Migration
  def change
    create_table :attribute_categories do |t|
      t.belongs_to :user
      t.string :entity_type
      t.string :name, null: false
      t.string :label, null: false
      t.string :icon
      t.text   :description
      t.timestamps
    end
    add_index :attribute_categories, :entity_type
    add_index :attribute_categories, :name

    create_table :attribute_fields do |t|
      t.belongs_to :user
      t.integer :attribute_category_id, null: false

      t.string :name, null: false
      t.string :label, null: false
      t.string :field_type, null: false
      t.text   :description
      t.string :privacy, default: 'private', null: false

      t.timestamps
    end
    add_index :attribute_fields, [:user_id, :name]

    create_table :attributes do |t|
      t.belongs_to :user
      t.integer :attribute_field_id

      # Polymorphic association to owning entity
      t.string  :entity_type, null: false
      t.integer :entity_id, null: false

      # Attribute values
      t.text    :value
      t.string  :privacy, default: 'private', null: false

      t.timestamps
    end
    add_index :attributes, [:user_id, :entity_type, :entity_id]
  end
end
