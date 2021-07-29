# frozen_string_literal: true

# Thredded configuration

# ==> User Configuration
# The name of the class your app uses for your users.
# By default the engine will use 'User' but if you have another name
# for your user class - change it here.
Thredded.user_class = 'User'

# User name column, used in @mention syntax and *must* be unique.
# This is the column used to search for users' names if/when someone is @ mentioned.
Thredded.user_name_column = :username

# User display name method, by default thredded uses the user_name_column defined above
# You may want to use :to_s or some more elaborate method
Thredded.user_display_name_method = :forum_username

# The path (or URL) you will use to link to your users' profiles.
# When linking to a user, Thredded will use this lambda to spit out
# the path or url to your user. This lambda is evaluated in the view context.
Thredded.user_path = lambda do |user|
  return nil if user && user.private_profile?

  user_path = :"#{Thredded.user_class_name.underscore}_path"
  main_app.respond_to?(user_path) ? main_app.send(user_path, user) : "/users/#{user.to_param}"
end

# This method is used by Thredded controllers and views to fetch the currently signed-in user
Thredded.current_user_method = :"current_#{Thredded.user_class_name.underscore}"

# User avatar URL. rb-gravatar gem is used by default:
Thredded.avatar_url = ->(user) { user.image_url }

# ==> Database Configuration
# By default, thredded uses integers for record ID route constraints.
# For integer based IDs (default):
# Thredded.routes_id_constraint = /[1-9]\d*/
# For UUID based IDs (example):
# Thredded.routes_id_constraint = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

# ==> Permissions Configuration
# By default, thredded uses a simple permission model, where all the users can post to all message boards,
# and admins and moderators are determined by a flag on the users table.

# The name of the moderator flag column on the users table.
Thredded.moderator_column = :forum_moderator
# The name of the admin flag column on the users table.
Thredded.admin_column = :forum_administrator

# Whether posts and topics pending moderation are visible to regular users.
Thredded.content_visible_while_pending_moderation = true

# Whether users that are following a topic are listed on topic page.
Thredded.show_topic_followers = true

# This model can be customized further by overriding a handful of methods on the User model.
# For more information, see app/models/thredded/user_extender.rb.

# ==> Ordering configuration

# How to calculate the position of messageboards in a list:
# :position            (default) set the position manually (new messageboards go to the bottom, by creation timestamp)
# :last_post_at_desc   most recent post first
# :topics_count_desc   most topics first
Thredded.messageboards_order = :last_post_at_desc

# ==> Email Configuration
# Email "From:" field will use the following
Thredded.email_from = 'notebook@indentlabs.com'

# Emails going out will prefix the "Subject:" with the following string
Thredded.email_outgoing_prefix = '[Notebook.ai] '
#
# The parent mailer for all Thredded mailers
# Thredded.parent_mailer = 'ActionMailer::Base'

# ==> View Configuration
# Set the layout for rendering the thredded views.
Thredded.layout = 'layouts/forum'

# ==> URLs
# How Thredded generates URL slugs from text.

# Default:
# Thredded.slugifier = ->(input) { input.parameterize }

# If your forum is in a language other than English, you might want to use the babosa gem instead
# Thredded.slugifier = ->(input) { Babosa::Identifier.new(input).normalize.transliterate(:russian).to_s }

# ==> Post Content Formatting
# Customize the way Thredded handles post formatting.

# Change the default html-pipeline filters used by thredded.
# E.g. to replace default emoji filter with your own:
# Thredded::ContentFormatter.after_markup_filters[
#   Thredded::ContentFormatter.after_markup_filters.index(HTML::Pipeline::EmojiFilter)] = MyEmojiFilter

# Change the HTML sanitization settings used by Thredded.
# See the Sanitize docs for more information on the underlying library: https://github.com/rgrove/sanitize/#readme
# E.g. to allow a custom element <custom-element>:
# Thredded::ContentFormatter.whitelist[:elements] += %w(custom-element)

# ==> User autocompletion (Private messages and @-mentions)
# Thredded.autocomplete_min_length = 2 lower to 1 if have 1-letter names -- increase if you want

# ==> Error Handling
# By default Thredded just renders a flash alert on errors such as Topic not found, or Login required.
# Below is an example of overriding the default behavior on LoginRequired:
#
# Rails.application.config.to_prepare do
#   Thredded::ApplicationController.module_eval do
#     rescue_from Thredded::Errors::LoginRequired do |exception|
#       @message = exception.message
#       render template: 'sessions/new', status: :forbidden
#     end
#   end
# end

# ==> View hooks
#
# Customize the UI before/after/replacing individual components.
# See the full list of view hooks and their arguments by running:
#
#     $ grep view_hooks -R --include '*.html.erb' "$(bundle show thredded)"
#
# Rails.application.config.to_prepare do
#   Thredded.view_hooks.post_form.content_text_area.config.before do |form:, **args|
#     # This is called in the Thredded view context, so all Thredded helpers and URLs are accessible here directly.
#     'hi'
#   end
# end

# ==> Topic following
#
# By default, a user will be subscribed to a topic they've created. Uncomment this to not subscribe them:
#
# Thredded.auto_follow_when_creating_topic = false
#
# By default, a user will be subscribed to (follow) a topic they post in. Uncomment this to not subscribe them:
#
# Thredded.auto_follow_when_posting_in_topic = false
#
# By default, a user will be subscribed to the topic they get @-mentioned in.
# Individual users can disable this in the Notification Settings.
# To change the default for all users, simply change the default value of the `follow_topics_on_mention` column
# of the `thredded_user_preferences` and `thredded_user_messageboard_preferences` tables.

# ==> Notifiers
#
# Change how users can choose to be notified, by adding notifiers here, or removing the initializer altogether
#
# default:
# Thredded.notifiers = [Thredded::EmailNotifier.new]
#
# none:
Thredded.notifiers = []
#
# add in (must install separate gem (under development) as well):
# Thredded.notifiers = [Thredded::EmailNotifier.new, Thredded::PushoverNotifier.new(ENV['PUSHOVER_APP_ID'])]

module AllowUsersToDeleteOwnTopics
  def destroy?
    super || @topic.user_id == @user.id
  end
end

module AllowAdminModeration
  def read?
    super || @user.thredded_admin?
  end
end

Rails.application.config.to_prepare do
  Thredded::TopicPolicy.prepend AllowUsersToDeleteOwnTopics
  Thredded::PrivateTopicPolicy.prepend AllowAdminModeration

  # This works for Onebox 1.x, but we'll probably need to switch over to the new AllowedGenericWhitelistOnebox (or whatever it's named)
  # when we upgrade to Onebox 2.x.
  Onebox::Engine::WhitelistedGenericOnebox.whitelist << "notebook.ai"
  Onebox::Engine::WhitelistedGenericOnebox.whitelist << "papercut-server.herokuapp.com"
end

Rails.application.config.to_prepare do
  Thredded::ApplicationController.module_eval do
    before_action :set_navbar_color
    before_action :set_navbar_actions
    before_action :set_sidenav_expansion

    def set_navbar_color
      if content_type = related_content_type
        @navbar_color = content_type.to_s.constantize.hex_color
      end
    end

    def set_navbar_actions
      return unless user_signed_in?
      content_type = related_content_type
      return if content_type.nil?

      content_type = content_type.to_s.constantize
      @navbar_actions = [
        {
          label: "Your #{view_context.pluralize @current_user_content.fetch(content_type.name, []).count, content_type.name.downcase}",
          href: main_app.polymorphic_path(content_type)
        },
        {
          label: "New #{content_type.name.downcase}",
          href: main_app.new_polymorphic_path(content_type)
        }
      ]

      discussions_link = ForumsLinkbuilderService.worldbuilding_url(content_type)
      if discussions_link.present?
        @navbar_actions << {
          label: 'Discussions',
          href: discussions_link,
          class: ForumsLinkbuilderService.is_discussions_page?(request.env['REQUEST_PATH']) ? 'active' : nil
        }
      end

      @navbar_actions << {
        label: 'Customize template',
        href: main_app.attribute_customization_path(content_type.name.downcase),
        class: 'right'
      }
    end

    def set_sidenav_expansion
      if related_content_type.present?
        @sidenav_expansion = 'worldbuilding'
      else
        @sidenav_expansion = 'community'
      end
    end

    private

    def related_content_type
      current_path = request.env['REQUEST_PATH']
      match = ForumsLinkbuilderService.content_to_url_map.detect { |key, base_url| current_path.start_with?(base_url) }

      if match
        return match[0] # class
      else
        return nil
      end
    end

  end
end

require 'extensions/thredded/topic'
require 'extensions/thredded/post'

Rails.application.config.to_prepare do
  begin
    if ActiveRecord::Base.connection.table_exists?(:thredded_topics)
      Thredded::Topic.include(Extensions::Thredded::Topic)
    end
  rescue ActiveRecord::NoDatabaseError
  end

  begin
    if ActiveRecord::Base.connection.table_exists?(:thredded_posts)
      Thredded::Post.include(Extensions::Thredded::Post)
    end
  rescue ActiveRecord::NoDatabaseError
  end
end
