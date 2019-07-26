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
