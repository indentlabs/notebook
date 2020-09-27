namespace :daily do
  desc "Delete thredded posts designated as spam"
  task clear_thredded_spam: :environment do
    Thredded::Post.where(moderation_state: "blocked").destroy_all
    Thredded::Topic.where(moderation_state: "blocked").destroy_all
  end
end
