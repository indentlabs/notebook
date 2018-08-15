class CreateArtifactship < ActiveRecord::Migration[4.2]
  def change
    create_table :artifactships do |t|
      t.integer :religion_id
      t.integer :artifact_id
      t.integer :user_id
    end
  end
end
