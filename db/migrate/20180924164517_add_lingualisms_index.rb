class AddLingualismsIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :lingualisms, :spoken_language_id
  end
end
