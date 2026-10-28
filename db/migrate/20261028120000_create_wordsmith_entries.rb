class CreateWordsmithEntries < ActiveRecord::Migration[6.1]
  def change
    # Offline reference data for the Wordsmith panel in the document editor.
    # Populated by `rake wordsmith:import`; see docs/wordsmith.md.
    create_table :wordsmith_entries do |t|
      t.string  :word, null: false
      t.text    :senses           # JSON: WordNet definitions, examples, synonyms, antonyms
      t.text    :related          # JSON: Moby Thesaurus related words
      t.string  :pronunciation    # CMU ARPAbet, e.g. "K AA1 N S T AH0 N T L IY0"
      t.integer :syllables
      t.string  :rhyme_key
      t.string  :near_rhyme_key
      t.boolean :common, null: false, default: false # Real dictionary word (not a name/acronym); used to filter rhymes
    end

    add_index :wordsmith_entries, :word, unique: true
    add_index :wordsmith_entries, [:rhyme_key, :common]
    add_index :wordsmith_entries, [:near_rhyme_key, :common]
  end
end
