namespace :one_off do
  desc "Create a notification for all users telling them about the new notifications"
  task notifications_announcement: :environment do
    User.all.find_each do |user|
      user.notifications.create(
        message_html: '<div>A new feature is now available:</div><div class="blue-text text-darken-3">Notifications on Notebook.ai</div>',
        icon:         'favorite',
        icon_color:   'red',
        happened_at:  DateTime.current,
        passthrough_link: 'https://medium.com/indent-labs/notifications-on-notebook-ai-693544b676cb'
      )
    end
  end
end
