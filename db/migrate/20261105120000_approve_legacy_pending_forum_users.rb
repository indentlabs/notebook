# From 20170724114833_create_thredded until 20181101234459_disable_moderation_on_forums, a
# thredded_user_details row defaulted to moderation_state 0 (pending_moderation). That later
# migration only changed the column default, so every forum account whose row was created in
# that window -- including the site's oldest staff accounts -- has been "pending" ever since.
# Their topics and posts inherit that state when they're created (Thredded's
# set_default_moderation_state), which went unnoticed because pending content is still public
# (Thredded.content_visible_while_pending_moderation).
#
# It started to matter once NotifyDiscordOfThreadJob began skipping every thread that isn't
# approved (so automoderation holds aren't announced): new threads from these accounts are now
# silently left off Discord, and because they already have pending posts the moderator ping is
# deduplicated away too. This approves those accounts so their new posts are approved again.
#
# Rows that a moderator or automoderation pended on purpose have moderation_state_changed_at set
# (Thredded::UserDetail sets it whenever moderation_state changes); legacy rows never changed,
# so it is still NULL on them. Staff are exempt from automoderation, so any pending staff row
# is approved as well.
#
# Existing topics and posts are left as they are: a pending post may also be one that somebody
# reported, and this migration can't tell those apart.
class ApproveLegacyPendingForumUsers < ActiveRecord::Migration[6.1]
  PENDING_MODERATION = 0
  APPROVED           = 1

  class MigrationUserDetail < ActiveRecord::Base
    self.table_name = 'thredded_user_details'
  end

  class MigrationUser < ActiveRecord::Base
    self.table_name = 'users'
  end

  def up
    pending = MigrationUserDetail.where(moderation_state: PENDING_MODERATION)

    staff_ids = MigrationUser.where(site_administrator: true)
                             .or(MigrationUser.where(forum_administrator: true))
                             .or(MigrationUser.where(forum_moderator: true))
                             .select(:id)

    pending.where(moderation_state_changed_at: nil)
           .or(pending.where(user_id: staff_ids))
           .update_all(moderation_state: APPROVED)
  end

  def down
    # Nothing to undo: the rows that were approved can't be told apart from other approved rows.
  end
end
