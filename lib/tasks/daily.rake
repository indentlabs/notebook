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

  desc "Auto-complete expired writing goals"
  task complete_expired_writing_goals: :environment do
    puts "Checking for expired writing goals..."

    completed_count = 0
    WritingGoal.where(archived: false, completed_at: nil)
               .where('end_date < ?', Date.current)
               .find_each do |goal|
      goal.update(completed_at: Time.current, active: false)
      completed_count += 1
      puts "  Completed: #{goal.title} (User ##{goal.user_id}, ended #{goal.end_date})"
    end

    puts "Done. Auto-completed #{completed_count} expired writing goals."
  end
end
