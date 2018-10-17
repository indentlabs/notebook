class AddPageTypeColumnToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :universes, :page_type,    :string
    add_column :characters, :page_type,   :string
    add_column :countries, :page_type,    :string
    add_column :creatures, :page_type,    :string
    add_column :deities, :page_type,      :string
    add_column :floras, :page_type,       :string
    add_column :governments, :page_type,  :string
    add_column :groups, :page_type,       :string
    add_column :items, :page_type,        :string
    add_column :landmarks, :page_type,    :string
    add_column :languages, :page_type,    :string
    add_column :locations, :page_type,    :string
    add_column :magics, :page_type,       :string
    add_column :planets, :page_type,      :string
    add_column :races, :page_type,        :string
    add_column :religions, :page_type,    :string
    add_column :scenes, :page_type,       :string
    add_column :technologies, :page_type, :string
    add_column :towns, :page_type,        :string
  end
end
