namespace :word_count do
  desc "Clean up duplicate Attribute records that cause inflated word counts (DRY_RUN=true for preview)"
  task cleanup_duplicate_attributes: :environment do
    dry_run = ENV['DRY_RUN'] != 'false'
    batch_size = (ENV['BATCH_SIZE'] || 1000).to_i

    puts dry_run ? "=== DRY RUN MODE ===" : "=== EXECUTING CLEANUP ==="
    puts ""

    # Find duplicate sets using GROUP BY (doesn't load all rows into memory)
    duplicates = Attribute
      .where(deleted_at: nil)
      .group(:entity_type, :entity_id, :attribute_field_id)
      .having('count(*) > 1')
      .pluck(:entity_type, :entity_id, :attribute_field_id)

    puts "Found #{duplicates.size} duplicate sets to process"
    puts ""

    total_deleted = 0
    sample_deletions = []

    duplicates.each_with_index do |(entity_type, entity_id, field_id), idx|
      # Small query per set - typically 2-3 rows
      attrs = Attribute.where(
        entity_type: entity_type,
        entity_id: entity_id,
        attribute_field_id: field_id,
        deleted_at: nil
      ).order(updated_at: :desc)

      keeper = attrs.first
      to_delete = attrs.offset(1)
      delete_count = to_delete.count

      # Collect samples for dry-run report
      if dry_run && sample_deletions.size < 10
        to_delete.limit(3).each do |attr|
          sample_deletions << {
            id: attr.id,
            entity: "#{attr.entity_type}##{attr.entity_id}",
            field_id: attr.attribute_field_id,
            value_preview: attr.value.to_s.truncate(50)
          }
        end
      end

      unless dry_run
        # Soft delete duplicates (respects acts_as_paranoid)
        to_delete.update_all(deleted_at: Time.current)
      end

      total_deleted += delete_count

      if (idx + 1) % 100 == 0
        puts "Progress: #{idx + 1}/#{duplicates.size} sets processed (#{total_deleted} duplicates #{dry_run ? 'found' : 'deleted'})"
      end
    end

    puts ""
    puts "Total duplicate records #{dry_run ? 'that would be' : ''} soft-deleted: #{total_deleted}"

    if dry_run && sample_deletions.any?
      puts ""
      puts "Sample of records that would be deleted:"
      sample_deletions.each do |s|
        puts "  - Attribute##{s[:id]}: #{s[:entity]}, field_id=#{s[:field_id]}"
        puts "    Value: #{s[:value_preview]}"
      end
      puts ""
      puts "To execute cleanup, run: rails word_count:cleanup_duplicate_attributes DRY_RUN=false"
    end
  end

  desc "Remove duplicate WordCountUpdate records in batches (DRY_RUN=true for preview)"
  task cleanup_duplicates: :environment do
    dry_run = ENV['DRY_RUN'] != 'false'  # Default to dry-run mode
    batch_size = 10_000

    puts dry_run ? "=== DRY RUN MODE (no changes will be made) ===" : "=== EXECUTING CLEANUP ==="
    puts ""

    # Find duplicate groups
    duplicates = WordCountUpdate
      .select(:entity_type, :entity_id, :for_date)
      .group(:entity_type, :entity_id, :for_date)
      .having('COUNT(*) > 1')
      .pluck(:entity_type, :entity_id, :for_date)

    puts "Found #{duplicates.count} duplicate groups"

    total_to_delete = 0
    sample_deletions = []

    duplicates.each_slice(batch_size).with_index do |batch, i|
      batch.each do |entity_type, entity_id, for_date|
        # Keep the record with highest id (most recent)
        records = WordCountUpdate.where(
          entity_type: entity_type,
          entity_id: entity_id,
          for_date: for_date
        ).order(id: :desc)

        to_delete = records.offset(1)
        delete_count = to_delete.count
        total_to_delete += delete_count

        # Collect samples for dry-run report
        if dry_run && sample_deletions.size < 10
          to_delete.limit(3).each do |record|
            sample_deletions << {
              id: record.id,
              entity: "#{record.entity_type}##{record.entity_id}",
              date: record.for_date,
              word_count: record.word_count
            }
          end
        end

        # Actually delete only if not dry-run
        to_delete.delete_all unless dry_run
      end

      puts "Processed batch #{i + 1} (#{(i + 1) * batch_size} groups)"
      sleep(0.1) unless dry_run  # Small delay to reduce DB load
    end

    puts ""
    puts "Total records that #{dry_run ? 'would be' : 'were'} deleted: #{total_to_delete}"

    if dry_run && sample_deletions.any?
      puts ""
      puts "Sample of records that would be deleted:"
      sample_deletions.each do |s|
        puts "  - ID #{s[:id]}: #{s[:entity]} on #{s[:date]} (word_count: #{s[:word_count]})"
      end
      puts ""
      puts "To execute cleanup, run: rails word_count:cleanup_duplicates DRY_RUN=false"
    end
  end
end
