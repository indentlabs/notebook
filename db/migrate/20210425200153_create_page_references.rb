class CreatePageReferences < ActiveRecord::Migration[6.0]
  def change
    create_table :page_references do |t|
      t.references :referencing_page, polymorphic: true, null: false, index: { name: :page_reference_referencing_page }
      t.references :referenced_page, polymorphic: true, null: false,  index: { name: :page_reference_referenced_page }
      t.references :attribute_field, null: true, foreign_key: true
      t.string :cached_relation_title

      t.timestamps
    end
  end
end
