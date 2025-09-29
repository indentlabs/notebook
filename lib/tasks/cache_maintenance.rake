namespace :cache do
  desc "Clear old cache files (older than 7 days)"
  task :clear_old => :environment do
    cache_dir = Rails.root.join('tmp', 'cache')

    if Dir.exist?(cache_dir)
      # Count files before cleanup
      count_before = Dir.glob(File.join(cache_dir, '**', '*')).select { |file| File.file?(file) }.count

      # Remove files older than 7 days
      cutoff_time = 7.days.ago
      removed_count = 0

      Dir.glob(File.join(cache_dir, '**', '*')).each do |file|
        if File.file?(file) && File.mtime(file) < cutoff_time
          begin
            File.delete(file)
            removed_count += 1
          rescue => e
            Rails.logger.error "Failed to delete cache file #{file}: #{e.message}"
          end
        end
      end

      # Remove empty directories
      Dir.glob(File.join(cache_dir, '**', '*')).reverse.each do |dir|
        if File.directory?(dir) && Dir.empty?(dir)
          begin
            Dir.rmdir(dir)
          rescue => e
            Rails.logger.error "Failed to remove empty directory #{dir}: #{e.message}"
          end
        end
      end

      count_after = Dir.glob(File.join(cache_dir, '**', '*')).select { |file| File.file?(file) }.count

      puts "Cache cleanup complete:"
      puts "  Files before: #{count_before}"
      puts "  Files removed: #{removed_count}"
      puts "  Files after: #{count_after}"

      Rails.logger.info "Cache cleanup: removed #{removed_count} files older than 7 days"
    else
      puts "Cache directory does not exist: #{cache_dir}"
    end
  end

  desc "Clear all cache files (use with caution)"
  task :clear_all => :environment do
    Rails.cache.clear
    puts "All cache files have been cleared"
  end

  desc "Show cache statistics"
  task :stats => :environment do
    cache_dir = Rails.root.join('tmp', 'cache')

    if Dir.exist?(cache_dir)
      files = Dir.glob(File.join(cache_dir, '**', '*')).select { |f| File.file?(f) }

      total_files = files.count
      total_size = files.sum { |f| File.size(f) rescue 0 }

      # Group by age
      now = Time.now
      age_groups = {
        "< 1 day" => 0,
        "1-7 days" => 0,
        "7-30 days" => 0,
        "> 30 days" => 0
      }

      files.each do |file|
        age_days = ((now - File.mtime(file)) / 86400).to_i rescue 999

        if age_days < 1
          age_groups["< 1 day"] += 1
        elsif age_days <= 7
          age_groups["1-7 days"] += 1
        elsif age_days <= 30
          age_groups["7-30 days"] += 1
        else
          age_groups["> 30 days"] += 1
        end
      end

      puts "Cache Statistics:"
      puts "  Total files: #{total_files}"
      puts "  Total size: #{(total_size / 1024.0 / 1024.0).round(2)} MB"
      puts ""
      puts "Files by age:"
      age_groups.each do |age, count|
        puts "  #{age}: #{count} files"
      end
    else
      puts "Cache directory does not exist: #{cache_dir}"
    end
  end
end