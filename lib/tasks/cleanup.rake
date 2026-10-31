namespace :cleanup do
  desc "Clear deleted content"
  task clear_deleted: :environment do
    days_to_keep = 14

    Rails.application.config.content_types[:all].each do |content_type|
      puts "Deleting #{content_type.name} older than #{days_to_keep} days..."
      content_type.where('deleted_at < ?', DateTime.current - days_to_keep.days).destroy_all
    end
  end
end

namespace :cleanup do
  # Forum posts whose topic no longer loads (it was soft-deleted, or removed
  # outright before topics were soft-deletable) aren't reachable anywhere on
  # the forum, but they still show up in anything that queries posts directly.
  # This soft-deletes them so they match their topic.
  #
  #   rake cleanup:orphaned_forum_posts           # report only
  #   rake cleanup:orphaned_forum_posts APPLY=1   # soft-delete them
  desc "Soft-delete forum posts whose topic is gone"
  task orphaned_forum_posts: :environment do
    orphans = Thredded::Post.where.not(postable_id: Thredded::Topic.select(:id))
    count = orphans.count

    puts "Found #{count} forum #{'post'.pluralize(count)} without a topic."
    next if count.zero?

    if ENV['APPLY'].present?
      # update_all skips post callbacks, which expect a topic to exist
      orphans.update_all(deleted_at: Time.current)
      puts "Soft-deleted #{count} #{'post'.pluralize(count)}."
    else
      puts "Run again with APPLY=1 to soft-delete them."
    end
  end
end
