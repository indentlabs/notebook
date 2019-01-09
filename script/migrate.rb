EMAIL_TO_MIGRATE_FROM = '***@gmail.com'
EMAIL_TO_MIGRATE_TO   = '***@gmail.com'

old_user = User.find_by!(email: EMAIL_TO_MIGRATE_FROM)
new_user = User.find_by!(email: EMAIL_TO_MIGRATE_TO)
exit "Invalid users" if old_user.nil? || new_user.nil?
exit "Users are the same" if old_user.id == new_user.id

CLASSES_TO_MIGRATE = Rails.application.config.content_types[:all] + [
  ContentChangeEvent, ApiKey, AttributeCategory, AttributeField, Attribute, Contributor, Document, ImageUpload, ReferralCode,
  Subscription, UserContentTypeActivator, Thredded::Post, Thredded::PrivateTopic
]

CLASSES_TO_MIGRATE.each do |klass|
  puts "Migrating #{klass.name}..."
  klass.where(user_id: old_user.id).update_all(user_id: new_user.id)
end
