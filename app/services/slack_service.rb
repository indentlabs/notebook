class SlackService < Service
  def self.post(channel, message)
    return unless Rails.env == 'production'
    slack_hook = ENV['SLACK_HOOK']
    return unless slack_hook

    Slack::Notifier.new(
      slack_hook,
      channel:  channel,
      username: 'tristan'
    ).ping(message)
  end
end