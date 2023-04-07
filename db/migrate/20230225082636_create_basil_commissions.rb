class CreateBasilCommissions < ActiveRecord::Migration[6.1]
  def change
    create_table :basil_commissions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :entity, polymorphic: true, null: false
      t.string :prompt
      t.string :job_id

      t.timestamps
    end
  end
end
