class ForumsProsifyService < Service
  ENDLINE = "\r\n"

  def self.visible_posts(thredded_topic, viewer)
    Thredded::PostPolicy::Scope.new(viewer, thredded_topic.posts).resolve
  end

  def self.prosify_text(thredded_topic, viewer, strip_parentheticals=true)
    prose = ""

    visible_posts(thredded_topic, viewer).find_each do |post|
      paragraphs = post.content.split(ENDLINE)

      paragraphs.each do |paragraph|
        prose += "\t#{paragraph}#{ENDLINE}" unless strip_parentheticals && post.content.start_with?('(') && post.content.end_with?(')')
      end
    end

    prose
  end

  def self.prosify_irc_log(thredded_topic, viewer, strip_parentheticals=true)
    prose = "-!- Topic: #{thredded_topic.title}#{ENDLINE}"
    user_display_name_cache = {}

    visible_posts(thredded_topic, viewer).find_each do |post|
      paragraphs = post.content.split(ENDLINE)
      user_display_name_cache[post.user_id] = post.user.try(:display_name) || "Anonymous" unless user_display_name_cache.key?(post.user_id)

      paragraphs.each do |paragraph|
        next if paragraph.empty?
        next if strip_parentheticals && post.content.start_with?('(') && post.content.end_with?(')')

        prose += "<#{user_display_name_cache[post.user_id]}> #{paragraph}#{ENDLINE}"
      end
    end

    prose
  end

  def self.prosify_html(thredded_topic, viewer, strip_parentheticals=true)
    prose = ""
    user_display_name_cache = {}

    visible_posts(thredded_topic, viewer).find_each do |post|
      user_display_name_cache[post.user_id] = post.user.try(:display_name) || "Anonymous user" unless user_display_name_cache.key?(post.user_id)

      tooltip = "authored by #{user_display_name_cache[post.user_id]}"
      prose += "<p class='tooltipped' data-tooltip='#{tooltip}' data-position='right'>#{post.content}</p>" unless strip_parentheticals && post.content.start_with?('(') && post.content.end_with?(')')
    end

    prose
  end

  def self.save_to_document(user, thredded_topic, strip_parentheticals=true)
    document = user.documents.create!(
      title: "#{thredded_topic.title} (forums post)",
      body:  prosify_html(thredded_topic, user, strip_parentheticals)
    )
    analysis = document.document_analysis.create!

    # If there are any links to Notebook.ai pages or [[page-id]] tokens in this post, we should automatically link those pages
    tokens = ContentFormatterService.tokens_to_replace(document.body)
    tokens.each do |token|
      next unless readable_page?(user, token[:content_type], token[:content_id])

      analysis.document_entities.find_or_create_by(
        entity_type: token[:content_type],
        entity_id:   token[:content_id]
      )
    end

    links = ContentFormatterService.links_to_replace(document.body)
    links.compact.each do |link|
      next unless readable_page?(user, link[:content_type], link[:content_id])

      analysis.document_entities.find_or_create_by(
        entity_type: link[:content_type],
        entity_id:   link[:content_id],
        text:        link[:matched_string]
      )
    end

    document
  end

  # Linking a page shows its details in the document, so only link pages the user can read
  def self.readable_page?(user, content_type, content_id)
    page_type = content_type.to_s.titleize
    return false unless ContentFormatterService::VALID_LINK_CLASSES.include?(page_type)

    page_type.constantize.find_by(id: content_id)&.readable_by?(user)
  end
end