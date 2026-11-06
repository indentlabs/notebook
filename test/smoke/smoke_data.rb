# The world RouteSmokeTest requests every page against.
#
# Everything is owned by one premium writer. A collaborator contributes to
# their universe, a stranger is just another signed-in user, a newcomer has
# just signed up and hasn't confirmed their email address yet, and an admin
# moderates the site. Keep it realistic: when production has a kind of record
# a page might trip on, add one here.
# The document analysis services run in the Sidekiq worker, which loads the
# :worker gem group (see Gemfile); tests don't, so load what they use.
require 'textstat'
require 'engtagger'

class SmokeData
  attr_reader :owner, :collaborator, :stranger, :newcomer, :admin,
              :universe, :pages, :document, :revision, :folder, :book, :timeline,
              :collection, :submission, :share, :share_comment, :notification,
              :writing_goal, :integration, :category, :field, :tag,
              :basil_commission, :promo_code,
              :messageboard, :messageboard_group, :forum_category, :topic, :post,
              :private_topic, :private_post

  def self.build!
    new.tap(&:build!)
  end

  def user_for(role)
    case role
    when :owner        then owner
    when :collaborator then collaborator
    when :stranger     then stranger
    when :newcomer     then newcomer
    when :admin        then admin
    when :anonymous    then nil
    else raise ArgumentError, "unknown role #{role}"
    end
  end

  def page(class_name)
    pages[class_name.to_s]
  end

  # 'characters' => Character, 'universes' => nil (handled separately)
  def content_class_for_controller(controller)
    klass = pages.values.map(&:class).find { |k| k.name.underscore.pluralize == controller }
    klass unless klass == Universe
  end

  def build!
    build_users
    build_universe_and_pages
    build_writing
    build_sharing
    build_account_records
    build_forum
    build_messy_records
  end

  private

  def make_user(name, **attrs)
    User.create!(
      {
        name:      name.titleize,
        email:     "smoke-#{name}@example.com",
        username:  "smoke-#{name}",
        password:  'password',
        time_zone: 'UTC',
        created_at: 1.month.ago,
        confirmed_at: 1.month.ago,
        # Production users get a Stripe customer when they sign up (see
        # User#initialize_stripe_customer). Billing pages then call Stripe,
        # which WebMock blocks and RouteSmokeTest skips past.
        stripe_customer_id: "cus_smoke_#{name}",
        current_sign_in_at: 1.hour.ago,
        current_sign_in_ip: '127.0.0.1'
      }.merge(attrs)
    )
  end

  def build_users
    @owner        = make_user('owner', selected_billing_plan_id: BillingPlan::PREMIUM_IDS.first, upload_bandwidth_kb: 100_000)
    @collaborator = make_user('collaborator')
    @stranger     = make_user('stranger')
    @newcomer     = make_user('newcomer', created_at: 1.hour.ago, confirmed_at: nil)
    @admin        = make_user('admin', site_administrator: true, forum_moderator: true)
    @owner.update_columns(secure_code: 'smoke-secure-code') if User.column_names.include?('secure_code')
  end

  def build_universe_and_pages
    @universe = Universe.create!(user: owner, name: 'Smoke Universe', privacy: 'public', description: 'A world for smoke testing')
    Contributor.create!(universe: universe, user: collaborator, email: collaborator.email)

    @pages = { 'Universe' => universe }
    Rails.application.config.content_types[:all].each do |klass|
      next if klass == Universe

      @pages[klass.name] = klass.create!(user: owner, universe: universe, name: "Smoke #{klass.name}", privacy: 'public')
    end

    # Pages a visitor without access shouldn't see, so the access checks run too.
    Character.create!(user: owner, universe: universe, name: 'Private Smoke Character', privacy: 'private')

    @tag = PageTag.create!(user: owner, page: page('Character'), tag: 'Smoke Tag', slug: 'smoke-tag')

    # Building the template for a page creates its categories and fields.
    character = page('Character')
    @category = AttributeCategory.find_by(user: owner, entity_type: 'character') ||
                AttributeCategory.create!(user: owner, entity_type: 'character', name: 'smoke_overview', label: 'Overview')
    @field    = AttributeField.where(attribute_category: @category).first ||
                AttributeField.create!(user: owner, attribute_category: @category, name: 'smoke_field', label: 'Smoke Field', field_type: 'text_area')
    Attribute.create!(user: owner, attribute_field: @field, entity_type: 'Character', entity_id: character.id, value: 'A value', privacy: 'public')

    @timeline = Timeline.create!(user: owner, universe: universe, name: 'Smoke Timeline', privacy: 'public')
  end

  def build_writing
    @folder   = Folder.create!(user: owner, title: 'Smoke Folder', context: 'Document')
    @document = Document.create!(user: owner, universe: universe, title: 'Smoke Document',
                                 body: '<p>Smoke Character walked into Smoke Location. It was a dark and stormy night, ' \
                                       'and the rain fell in torrents. "Who goes there?" asked the guard, quietly.</p>' \
                                       '<p>Nobody answered. The wind howled through the empty streets of the old town.</p>',
                                 privacy: 'public',
                                 folder: folder)
    @revision = DocumentRevision.create!(document: document, title: document.title, body: document.body)
    # Run the analysis steps that don't call outside services (DocumentAnalysisJob
    # also asks IBM Watson), so the analysis pages have real numbers to show.
    analysis = DocumentAnalysis.create!(document: document, queued_at: 1.hour.ago)
    [
      Documents::Analysis::CountingService,
      Documents::Analysis::ReadabilityService,
      Documents::Analysis::ContentService,
      Documents::Analysis::PartsOfSpeechService,
    ].each { |service| service.analyze(analysis.id) }
    analysis.update!(progress: 100, completed_at: Time.current)
    DocumentEntity.create!(document_analysis: analysis, entity: page('Character'), text: 'Smoke Character', relevance: 0.9)
    # An entity the analysis found but nobody linked to a page yet.
    DocumentEntity.create!(document_analysis: analysis, entity_type: 'Location', text: 'Smoke Location', relevance: 0.5)

    @book = Book.create!(user: owner, universe: universe, name: 'Smoke Book', privacy: 'public')
    BookDocument.create!(book: book, document: document, position: 1)

    @writing_goal = WritingGoal.create!(user: owner, title: 'Smoke Goal', target_word_count: 1000,
                                        start_date: Date.current - 7, end_date: Date.current + 7)
    WordCountUpdate.create!(user: owner, entity: document, word_count: 120, for_date: Date.current)
  end

  def build_sharing
    @collection = PageCollection.create!(user: owner, title: 'Smoke Collection', privacy: 'public',
                                         page_types: %w[Character Location Item], allow_submissions: true)
    @submission = PageCollectionSubmission.create!(page_collection: collection, user: owner,
                                                   content_type: 'Character', content_id: page('Character').id,
                                                   submitted_at: Time.current, accepted_at: Time.current)
    PageCollectionSubmission.create!(page_collection: collection, user: stranger,
                                     content_type: 'Location', content_id: page('Location').id,
                                     submitted_at: Time.current)

    @share = ContentPageShare.create!(user: owner, content_page: page('Character'), privacy: 'public',
                                      shared_at: Time.current, message: 'Look at my character')
    @share_comment = ShareComment.create!(user: stranger, content_page_share: share, message: 'Nice!')

    UserFollowing.create!(user_id: stranger.id, followed_user_id: owner.id)
  end

  def build_account_records
    @notification = Notification.create!(user: owner, message_html: '<p>Smoke notification</p>',
                                         happened_at: Time.current, reference_code: 'smoke-reference',
                                         passthrough_link: '/my/dashboard')
    @integration  = ApplicationIntegration.create!(user: owner, name: 'Smoke Integration')
    @basil_commission = BasilCommission.create!(user: owner, entity: page('Character'), prompt: 'A smoke test',
                                                job_id: 'smoke-job', style: 'realistic', completed_at: Time.current)
    @promo_code = PageUnlockPromoCode.create!(code: 'SMOKECODE', page_types: %w[Creature Flora], uses_remaining: 5, days_active: 7)
  end

  def build_forum
    @messageboard_group = Thredded::MessageboardGroup.create!(name: 'Smoke Group')
    @messageboard = Thredded::Messageboard.create!(name: 'Smoke Board', messageboard_group_id: messageboard_group.id)
    @forum_category = Thredded::Category.create!(messageboard: messageboard, name: 'Smoke Category')

    form = Thredded::TopicForm.new(title: 'Smoke topic', content: 'First post', user: owner, messageboard: messageboard)
    form.save || raise("Couldn't create smoke topic: #{form.errors.full_messages.to_sentence}")
    @topic = form.topic.reload
    @post  = topic.posts.create!(content: 'A reply', user: stranger, messageboard: messageboard)

    private_form = Thredded::PrivateTopicForm.new(title: 'Smoke DM', content: 'Hello', user: owner, user_ids: [stranger.id])
    private_form.save || raise("Couldn't create smoke DM: #{private_form.errors.full_messages.to_sentence}")
    @private_topic = private_form.private_topic.reload
    @private_post  = private_topic.posts.first
    # Admins see every DM (hate/spam watch), so give one a deleted author.
    Thredded::PrivatePost.create!(postable: private_topic, user: stranger, content: 'From a deleted user').update_columns(user_id: nil)
  end

  # Records shaped like the ones that have caused 500s in production.
  def build_messy_records
    # A page with nothing filled in but its name.
    Location.create!(user: owner, universe: universe, name: 'Bare Smoke Location', privacy: 'public')
    # A page outside any universe.
    Item.create!(user: owner, name: 'Universe-less Smoke Item', privacy: 'public')
    # A tag on a page that has since been deleted.
    deleted = Character.create!(user: owner, universe: universe, name: 'Deleted Smoke Character', privacy: 'public')
    PageTag.create!(user: owner, page: deleted, tag: 'Smoke Tag', slug: 'smoke-tag')
    deleted.destroy
    # A forum post whose author deleted their account.
    topic.posts.create!(content: 'Orphaned reply', user: stranger, messageboard: messageboard).update_columns(user_id: nil)
    # A share of a page that has since been deleted.
    gone = Item.create!(user: owner, universe: universe, name: 'Shared Then Deleted', privacy: 'public')
    ContentPageShare.create!(user: owner, content_page: gone, privacy: 'public', shared_at: 1.hour.ago, message: 'Gone soon')
    gone.destroy
    # A notification with no link.
    Notification.create!(user: owner, message_html: '<p>No link</p>', happened_at: 1.day.ago)
  end
end
