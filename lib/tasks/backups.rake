namespace :backups do
  desc "Export all data to CSV"
  task export_to_csv: :environment do 
    require 'csv'
 
    export_folder = "./export"
    FileUtils.mkdir_p(export_folder) unless File.exists?(export_folder)
    exported_tables = []
    skipped_tables = []

    puts "Starting CSV export"
    ActiveRecord::Base.connection.tables.each do |table_name|
      file = "#{export_folder}/#{table_name}.csv"
    
      begin
        klass = table_name.classify.constantize
      rescue NameError
        # If we can't classify the name (e.g. it's namespaced), try to pull it from ActiveRecord::Base.descendants
        klass = ActiveRecord::Base.descendants.find { |d| d.table_name == table_name }

        # If we still can't find it, skip it.
        if klass.nil?
          puts "  !!!  Skipping table #{table_name} (no model)"
          skipped_tables << table_name
          next
        end
      end

      table = klass.all;0 # ";0" stops output.
      if table.any?
        print "  #{"%.3d" % (exported_tables.count + 1)}. Exporting table #{table_name} (#{klass.name}) to #{file}..."
        exported_tables << table_name
        CSV.open( file, 'w' ) do |writer|
          writer << table.first.attributes.map { |a,v| a }
          table.find_each do |s|
            writer << s.attributes.map { |a,v| v }
          end
        end
        puts "Done."
      else
        puts "  !!!  Skipping table #{table_name} (no data)"
        skipped_tables << table_name
      end
    end

    puts "Tables exported: #{exported_tables.join(', ')}"
    puts "Tables skipped: #{skipped_tables.join(', ')}"
  end
end