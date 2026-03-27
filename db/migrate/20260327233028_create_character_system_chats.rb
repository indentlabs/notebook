class CreateCharacterSystemChats < ActiveRecord::Migration[6.1]
  def change
    create_table :character_system_chats do |t|
      t.integer :character_id, index: true
      t.integer :user_id, index: true
      t.string :uid, index: { unique: true }
      t.json :messages, default: []

      t.timestamps
    end
  end
end
