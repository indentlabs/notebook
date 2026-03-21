namespace :documents do
  desc "Recalculate cached_word_count for all documents"
  task recalculate_word_counts: :environment do
    total = Document.count
    fixed = 0

    puts "Processing #{total} documents..."
    puts ""

    Document.find_each.with_index do |doc, index|
      new_count = doc.computed_word_count
      if doc.cached_word_count != new_count
        puts "#{index + 1}/#{total}: Document #{doc.id} '#{doc.title.to_s.truncate(30)}': #{doc.cached_word_count || 'nil'} -> #{new_count}"
        doc.update_column(:cached_word_count, new_count)
        fixed += 1
      end
      print "." if (index + 1) % 100 == 0
    end

    puts ""
    puts "Done. Fixed #{fixed} documents out of #{total}."
  end
end
