class AddDefaultsToNewPageColumns < ActiveRecord::Migration[5.2]
  def up
    change_column :universes, :page_type,    :string, default: 'Universe'
    change_column :characters, :page_type,   :string, default: 'Character'
    change_column :countries, :page_type,    :string, default: 'Country'
    change_column :creatures, :page_type,    :string, default: 'Creature'
    change_column :deities, :page_type,      :string, default: 'Deity'
    change_column :floras, :page_type,       :string, default: 'Flora'
    change_column :governments, :page_type,  :string, default: 'Government'
    change_column :groups, :page_type,       :string, default: 'Group'
    change_column :items, :page_type,        :string, default: 'Item'
    change_column :landmarks, :page_type,    :string, default: 'Landmark'
    change_column :languages, :page_type,    :string, default: 'Language'
    change_column :locations, :page_type,    :string, default: 'Location'
    change_column :magics, :page_type,       :string, default: 'Magic'
    change_column :planets, :page_type,      :string, default: 'Planet'
    change_column :races, :page_type,        :string, default: 'Race'
    change_column :religions, :page_type,    :string, default: 'Religion'
    change_column :scenes, :page_type,       :string, default: 'Scene'
    change_column :technologies, :page_type, :string, default: 'Technology'
    change_column :towns, :page_type,        :string, default: 'Town'
  end

  def down
  end
end
