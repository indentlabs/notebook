class RemoveNullConstraintOnLoresUniverseId < ActiveRecord::Migration[6.0]
  def change
    change_column :lores, :universe_id, :integer, :null => true
  end
end
