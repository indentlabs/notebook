class AddUniverseToFlora < ActiveRecord::Migration
  def change
    add_reference :floras, :universe, index: true, foreign_key: true
  end
end
