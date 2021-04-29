class AddReferenceTypeToPageReferences < ActiveRecord::Migration[6.0]
  def change
    add_column :page_references, :reference_type, :string
  end
end
