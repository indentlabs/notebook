namespace :word_count do
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
