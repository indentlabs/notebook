require 'test_helper'
require 'webmock/minitest'
require_relative 'smoke_data'

# Requests every GET route in the app, as each kind of visitor, and fails if
# any of them raises an error that production would turn into a 500.
#
# Most of the 500s we ship come from a page calling a method, helper or
# constant that was renamed or removed. Nothing else in the suite renders
# every page, so those slipped through. This test does, so they can't.
#
# How it works:
#   * SmokeData builds one realistic world: a premium owner with a universe,
#     a page of every content type, documents, books, timelines, collections,
#     forum topics, and so on. Some of it is deliberately messy (blank fields,
#     a dangling link, an orphaned tag) because that is what production holds.
#   * Every GET route has its path parameters filled in from that world.
#   * Each request runs in a savepoint that is rolled back, so a GET that
#     changes data (follow/unfollow, destroy_* links) can't affect the next one.
#   * Each role makes every request, and every 5xx is collected so that one
#     run reports all the broken pages at once.
#
# When you add a route:
#   * If it's a GET route with a new path parameter, teach #param_value how
#     to fill it in, or "every GET route is smoke tested" will fail.
#   * If it can't be requested safely in a test (it signs you out, talks to
#     a payment provider, ...), add it to SKIPPED_ROUTES with the reason.
class RouteSmokeTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # "controller#action" => why the smoke test doesn't request it
  SKIPPED_ROUTES = {
    'sessions#destroy'                      => 'signs the visitor out, which would end the run for that role',
    'admin#masquerade'                      => 'signs the admin in as another user',
    'subscriptions#change'                  => 'changes the Stripe subscription; covered by subscriptions_controller_test',
    'subscriptions#prepay_redirect_to_paypal' => 'redirects to PayPal with a live invoice',
    'subscriptions#delete_payment_method'   => 'calls Stripe; covered by subscriptions_controller_test',
    'turbo/native/navigation#recede'        => 'Turbo Native bridge page, not part of the site',
    'turbo/native/navigation#resume'        => 'Turbo Native bridge page, not part of the site',
    'turbo/native/navigation#refresh'       => 'Turbo Native bridge page, not part of the site',
    'thredded/theme_previews#show'          => "Thredded's own theme preview, which builds unsaved demo records",
  }.freeze

  # Of the apps mounted in routes.rb, only the forum (Thredded) is crawled.
  # Rails Admin, Sidekiq's UI, the Stripe webhook receiver, Action Cable and
  # the asset server aren't pages of ours.

  # Rails' own routes (Active Storage, mailer previews, ...).
  SKIPPED_CONTROLLER_PREFIXES = %w[rails/ active_storage/ action_mailbox/].freeze

  ROLES = %i[owner collaborator stranger anonymous admin].freeze

  # The page reached for a service the test environment doesn't run: WebMock
  # blocks outside HTTP (Stripe, image hosts, ...) and CI has no Redis.
  # Production has both, and those pages are a matter for their own tests.
  OUTSIDE_SERVICE_ERRORS = %w[
    WebMock::NetConnectNotAllowedError
    RedisClient::CannotConnectError
    Redis::CannotConnectError
  ].freeze

  # A route that can't be built (missing parameter) is a gap in coverage.
  class UnresolvableRoute < StandardError; end

  # One route ready to request.
  SmokeRoute = Struct.new(:route, :prefix, :engine, keyword_init: true) do
    def controller = route.defaults[:controller].to_s
    def action     = route.defaults[:action].to_s
    def key        = "#{controller}##{action}"
    def spec       = "#{prefix}#{route.path.spec}"
    def redirect?
      endpoint = route.app.respond_to?(:rack_app) ? route.app.rack_app : route.app
      endpoint.respond_to?(:redirect?) && endpoint.redirect?
    end
  end

  def self.get_routes
    routes = []
    collect = lambda do |route_set, prefix, engine|
      route_set.routes.each do |route|
        if (app = mounted_app(route))
          mount_path = route.path.spec.to_s
          collect.call(app.routes, mount_path, app) if app == Thredded::Engine
          next
        end

        next unless route.verb.to_s.split('|').include?('GET')
        next if route.internal
        next if SKIPPED_CONTROLLER_PREFIXES.any? { |p| route.defaults[:controller].to_s.start_with?(p) }

        routes << SmokeRoute.new(route: route, prefix: prefix, engine: engine)
      end
    end
    collect.call(Rails.application.routes, '', nil)
    routes
  end

  # The engine or Rack app mounted at +route+, if it's a mount.
  def self.mounted_app(route)
    return nil unless route.app.respond_to?(:engine?) && route.app.engine?

    route.app.rack_app
  end

  setup do
    WebMock.disable_net_connect!(allow_localhost: false)
    @data = SmokeData.build!
  end

  ROLES.each do |role|
    test "no GET route returns a 5xx for #{role == :anonymous ? 'a logged-out visitor' : "the #{role}"}" do
      user = @data.user_for(role)
      sign_in(user) if user

      failures  = []
      requested = 0
      @rendered = 0
      self.class.get_routes.each do |smoke_route|
        next if SKIPPED_ROUTES.key?(smoke_route.key)

        requested += 1
        path = build_path(smoke_route)
        failure = request_and_check(path)
        failures << "#{smoke_route.key} GET #{path}\n      #{failure}" if failure
      end

      who = role == :anonymous ? 'a logged-out visitor' : "the #{role}"
      assert failures.empty?,
             "#{failures.size} page(s) returned a server error for #{who}:\n\n  #{failures.join("\n\n  ")}\n"

      # If signing in broke, every page would redirect to the login form and
      # this test would pass while checking nothing. Make sure pages render.
      minimum = (requested * (role == :owner ? 0.75 : 0.33)).floor
      assert @rendered >= minimum,
             "Only #{@rendered} of #{requested} pages rendered for #{who} (expected at least #{minimum}); " \
             "is SmokeData or sign-in broken?"
    end
  end

  test "every GET route is smoke tested or explicitly skipped" do
    unresolved = []
    self.class.get_routes.each do |smoke_route|
      next if SKIPPED_ROUTES.key?(smoke_route.key)

      begin
        build_path(smoke_route)
      rescue UnresolvableRoute => e
        unresolved << "#{smoke_route.key} #{smoke_route.spec}: #{e.message}"
      end
    end

    assert unresolved.empty?,
           "These GET routes can't be built, so they aren't smoke tested. Teach RouteSmokeTest#param_value " \
           "to fill in their parameters, or add them to SKIPPED_ROUTES with a reason:\n  #{unresolved.join("\n  ")}"
  end

  test "every skipped route still exists" do
    keys = self.class.get_routes.map(&:key)
    stale = SKIPPED_ROUTES.keys - keys
    assert stale.empty?, "Remove these from RouteSmokeTest::SKIPPED_ROUTES; the routes are gone: #{stale.join(', ')}"
  end

  private

  # Requests +path+ inside a savepoint that is always rolled back. Returns a
  # description of the failure, or nil if the page didn't 5xx.
  def request_and_check(path)
    failure = nil
    ActiveRecord::Base.transaction(requires_new: true) do
      begin
        get path
        @rendered += 1 if response.successful?
        failure = "responded #{response.status}" if response.status >= 500
      rescue StandardError, WebMock::NetConnectNotAllowedError => e # WebMock's error isn't a StandardError
        failure = describe_failure(e)
      end
      raise ActiveRecord::Rollback
    end
    failure
  end

  # The test environment raises exceptions instead of rendering error pages.
  # Production maps some of them to 4xx responses (RecordNotFound is a 404,
  # for instance), so only the ones it would serve as a 5xx count.
  def describe_failure(exception)
    cause = exception.is_a?(ActionView::Template::Error) && exception.cause ? exception.cause : exception
    return nil if OUTSIDE_SERVICE_ERRORS.any? { |name| cause.class.name == name || cause.class.ancestors.map(&:name).include?(name) }
    return nil if ActionDispatch::ExceptionWrapper.status_code_for_exception(cause.class.name) < 500

    "#{cause.class}: #{cause.message.to_s.lines.first.to_s.strip.truncate(300)}\n      at #{app_backtrace_line(exception)}"
  end

  def app_backtrace_line(exception)
    lines = Array(exception.backtrace)
    if exception.is_a?(ActionView::Template::Error) && exception.cause
      lines = Array(exception.cause.backtrace) + lines
    end
    app_line = lines.find { |l| l.start_with?(Rails.root.join('app').to_s) } || lines.first
    app_line.to_s.sub("#{Rails.root}/", '')
  end

  def build_path(smoke_route)
    route  = smoke_route.route
    params = {}
    route.required_parts.each do |name|
      value = param_value(name, smoke_route)
      raise UnresolvableRoute, "don't know what to use for :#{name}" if value.nil?
      params[name] = value.to_s
    end

    path = route.format(params)
    "#{smoke_route.prefix}#{path}".gsub(%r{//+}, '/').presence || '/'
  end

  # Fills in one path parameter for a route from the smoke-test world.
  def param_value(name, smoke_route)
    d = @data
    controller = smoke_route.controller

    if smoke_route.engine == Thredded::Engine
      return thredded_param_value(name, controller)
    end

    case name
    when :id               then id_for(smoke_route)
    when :user_id          then d.owner.id
    when :username         then d.owner.username
    when :universe_id      then d.universe.id
    when :document_id      then d.document.id
    when :page_collection_id then d.collection.id
    when :character_id     then d.page('Character').id
    when :scene_id         then d.page('Scene').id
    when :slug
      controller == 'thredded_proxy' ? d.topic.slug : d.tag.slug
    when :tag_slug         then d.tag.slug
    when :content_type
      # Basil and the attributes pages take it lowercase, the APIs as a class name.
      %w[basil content].include?(controller) ? 'character' : 'Character'
    when :entity_type, :page_type then 'Character'
    when :page_id          then d.page('Character').id
    when :category         then d.category.name
    when :field_label      then d.field.label
    when :type             then 'Character'
    when :model            then 'characters'
    when :year             then Date.current.year
    when :matchlist        then 'hate'
    when :reference_code   then d.notification.reference_code
    when :jobid            then d.basil_commission.job_id
    when :code
      controller == 'emails' ? d.owner.secure_code : d.promo_code.code
    end
  end

  def id_for(smoke_route)
    d          = @data
    controller = smoke_route.controller
    action     = smoke_route.action

    if smoke_route.redirect?
      # e.g. /plan/characters/:id/gallery
      plural = smoke_route.spec.split('/')[2].to_s
      return d.page(plural.classify)&.id
    end

    content_class = d.content_class_for_controller(controller)
    return d.page(content_class.name).id if content_class

    case controller
    when 'basil'                         then d.page('Character').id
    when 'users'                         then d.owner.id
    when 'universes', 'main'             then d.universe.id
    when 'documents', 'document_analyses' then d.document.id
    when 'document_revisions'            then d.revision.id
    when 'books'                         then d.book.id
    when 'timelines'                     then d.timeline.id
    when 'page_collections'              then d.collection.id
    when 'page_collection_submissions'   then d.submission.id
    when 'notifications'                 then d.notification.id
    when 'share_comments'                then d.share_comment.id
    when 'content_page_shares'           then d.share.id
    when 'writing_goals'                 then d.writing_goal.id
    when 'folders'                       then d.folder.id
    when 'api/application_integrations'  then d.integration.id
    when 'attribute_categories', 'api/v1/attribute_categories' then d.category.id
    when 'attribute_fields', 'api/v1/attribute_fields'         then d.field.id
    when 'api/v1/attributes'
      smoke_route.action == 'category_edit' ? d.category.id : d.field.id
    when 'api/v1/api'
      action == 'timeline' ? d.timeline.id : d.page(action.classify)&.id
    end
  end

  def thredded_param_value(name, controller)
    d = @data
    case name
    when :messageboard_id    then d.messageboard.slug
    when :topic_id           then d.topic.slug
    when :private_topic_id   then d.private_topic.slug
    when :category_id        then d.forum_category.id
    when :id
      case controller
      when 'thredded/topics'                  then d.topic.slug
      when 'thredded/posts', 'thredded/post_permalinks' then d.post.id
      when 'thredded/private_topics'          then d.private_topic.slug
      when 'thredded/private_posts', 'thredded/private_post_permalinks' then d.private_post.id
      when 'thredded/messageboards'           then d.messageboard.slug
      when 'thredded/messageboard_groups'     then d.messageboard_group.id
      when 'thredded/moderation'              then d.owner.id
      end
    end
  end
end
