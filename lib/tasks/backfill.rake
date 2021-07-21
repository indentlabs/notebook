namespace :backfill do
  desc "Backfill cached word counts on all documents"
  task document_word_count_caches: :environment do
    Document.with_deleted.where(cached_word_count: nil).where.not(body: [nil, ""]).find_each(batch_size: 500) do |document|
      document.update_column(:cached_word_count, document.computed_word_count)
      puts document.id
    end
  end

  desc "Start working through old categories/fields without position set"
  task sortables_positions: :environment do
    categories_to_position = AttributeCategory.where(position: nil).order("RANDOM()").limit(500).to_a

    puts "Empty position backlog:\n\t* #{AttributeCategory.where(position: nil).count} categories\n\t* #{AttributeField.where(position: nil).count} fields"

    while categories_to_position.any?
      category = categories_to_position.pop

      # Backfill all the positioning for this category's page's categories
      category.backfill_categories_ordering!

      # We can skip this if we're just backfilling with a single worker,
      # but in case we're backfilling on multiple this fetches a recent
      # copy of updates before proceeding. Technically still a possibility
      # of Doing The Same Thing Twice, but a smaller possibility.

      if rand(100) < 20
        puts "Empty position backlog:\n\t* #{AttributeCategory.where(position: nil).count} categories\n\t* #{AttributeField.where(position: nil).count} fields"
      end
    end

    puts "Done!"
  end
end

