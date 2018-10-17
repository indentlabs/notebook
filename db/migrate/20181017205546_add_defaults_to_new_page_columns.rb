class AddDefaultsToNewPageColumns < ActiveRecord::Migration[5.2]
  def change
    change_column_default :universes, :page_type, 'Universe'
    change_column_default :characters, :page_type, 'Character'
    change_column_default :countries, :page_type, 'Country'
    change_column_default :creatures, :page_type, 'Creature'
    change_column_default :deities, :page_type, 'Deity'
    change_column_default :floras, :page_type, 'Flora'
    change_column_default :governments, :page_type, 'Government'
    change_column_default :groups, :page_type, 'Group'
    change_column_default :items, :page_type, 'Item'
    change_column_default :landmarks, :page_type, 'Landmark'
    change_column_default :languages, :page_type, 'Language'
    change_column_default :locations, :page_type, 'Location'
    change_column_default :magics, :page_type, 'Magic'
    change_column_default :planets, :page_type, 'Planet'
    change_column_default :races, :page_type, 'Race'
    change_column_default :religions, :page_type, 'Religion'
    change_column_default :scenes, :page_type, 'Scene'
    change_column_default :technologies, :page_type, 'Technology'
    change_column_default :towns, :page_type, 'Town'
  end
end
