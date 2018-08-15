class AddUniverseToFlora < ActiveRecord::Migration[4.2]
  def change
    add_reference :floras, :universe, index: true, foreign_key: true
  end
end
