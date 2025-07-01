class AddPositionToBasilCommissions < ActiveRecord::Migration[6.1]
  def change
    add_column :basil_commissions, :position, :integer
    add_index :basil_commissions, [:entity_type, :entity_id, :position], name: 'index_basil_commissions_on_entity_position'
    
    # Backfill existing basil_commissions with positions based on save date
    reversible do |dir|
      dir.up do
        if connection.adapter_name.downcase.include?('postgres')
          # PostgreSQL-specific approach using window functions
          execute <<-SQL
            UPDATE basil_commissions
            SET position = t.seq
            FROM (
              SELECT id, ROW_NUMBER() OVER (
                PARTITION BY entity_type, entity_id
                ORDER BY saved_at ASC, id ASC
              ) as seq
              FROM basil_commissions
              WHERE saved_at IS NOT NULL
            ) as t
            WHERE basil_commissions.id = t.id
          SQL
        else
          # Database-agnostic approach using Ruby
          say_with_time("Backfilling positions for BasilCommissions") do
            BasilCommission.where.not(saved_at: nil).group_by { |img| [img.entity_type, img.entity_id] }.each do |group_key, images|
              ordered_images = images.sort_by { |img| [img.saved_at || Time.current, img.id] }
              ordered_images.each_with_index do |img, idx|
                img.update_column(:position, idx + 1)
              end
            end
          end
        end
      end
    end
  end
end
