class AddCommunityFeaturesEnabledFlagToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :community_features_enabled, :boolean
    change_column_default(:users, :community_features_enabled, true)

    User.where(community_features_enabled: nil).update_all(community_features_enabled: true)
  end
end
