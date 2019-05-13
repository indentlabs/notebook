puts "Turning off SQL logs"
old_logger = ActiveRecord::Base.logger
ActiveRecord::Base.logger = nil

to_migrate = User.all.pluck(:id) - AttributeCategory.pluck(:user_id).uniq

users_migrated = 1
to_migrate.first(50).each do |user_id|
    user = User.find(user_id)
    puts "Migrating user ##{user_id} #{user.email} (#{users_migrated}/#{to_migrate.count})"
    
    ActiveRecord::Base.transaction do 
        Rails.application.config.content_types[:all].each do |content_type|
            puts "\tMigrating #{content_type.name}..."
            content_type.create_default_attribute_categories(user)
        end
    end

    users_migrated += 1
end

puts "Turning SQL logging back on"
ActiveRecord::Base.logger = old_logger