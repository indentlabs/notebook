namespace :backfill do
  desc "Start working through old categories/fields without position set"
  task sortables_positions: :environment do
    categories_to_position = AttributeCategory.where(position: nil).to_a
    fields_to_position     = AttributeField.where(position: nil).to_a

    puts "Empty position backlog:\n\t- #{categories_to_position.count} categories\n\t- #{fields_to_position.count} fields"

    while categories_to_position.any?
      category = categories_to_position.pop

      # Backfill all the positioning for this category's page's categories
      category.backfill_categories_ordering!

      # We can skip this if we're just backfilling with a single worker,
      # but in case we're backfilling on multiple this fetches a recent
      # copy of updates before proceeding. Technically still a possibility
      # of Doing The Same Thing Twice, but a smaller possibility.
      categories_to_position = AttributeCategory.where(position: nil).to_a

      if rand(100) < 20
        puts "Empty position backlog:\n\t-#{categories_to_position.count} categories\n\t-#{fields_to_position.count} fields"
      end
    end
  end
end
