class AddFrequencyToWordsmithEntries < ActiveRecord::Migration[6.1]
  def change
    # Rough commonness score used to rank rhymes and related words; filled in
    # by `rake wordsmith:import`.
    add_column :wordsmith_entries, :frequency, :integer, null: false, default: 0
  end
end
