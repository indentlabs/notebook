class AddContributableContentIndexes < ActiveRecord::Migration[6.0]
  def change
    Rails.application.config.content_types[:all].each do |content_type|
      add_index(content_type.name.downcase.pluralize.to_sym, [:user_id, :universe_id, :deleted_at])
    end
  end
end
