namespace :daily do
  desc "Reset user following/followers counter caches"
  task reset_follow_counters: :environment do
    puts "Resetting user follow counter caches..."

    updated_count = 0
    User.find_each do |user|
      old_following = user.following_count
      old_followers = user.followers_count

      User.reset_counters(user.id, :user_followings)

      user.reload
      if old_following != user.following_count || old_followers != user.followers_count
        updated_count += 1
        puts "  User ##{user.id}: following #{old_following} -> #{user.following_count}, followers #{old_followers} -> #{user.followers_count}"
      end
    end

    puts "Done. Updated #{updated_count} users with incorrect counter caches."
  end

  desc "Delete thredded posts designated as spam"
  task clear_thredded_spam: :environment do
    Thredded::Post.where(moderation_state: "blocked").destroy_all
    Thredded::Topic.where(moderation_state: "blocked").destroy_all

    blocked_user_ids = Thredded::UserDetail.where(moderation_state: "blocked").pluck(:user_id)

    # Destroy all stream comments from blocked users and nil users
    ShareComment.where(user_id: blocked_user_ids).destroy_all
    ShareComment.where(user_id: nil).destroy_all
  end

  desc "Run end-of-day-analytics reporter"
  task eod_analytics: :environment do
    EndOfDayAnalyticsJob.perform_now
  end
end
