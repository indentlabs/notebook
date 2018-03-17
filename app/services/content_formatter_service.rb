class ContentFormatterService < Service
  extend ActionView::Helpers::UrlHelper # link_to, *_url, *_path
  extend ActionView::Helpers::TagHelper # content_tag (used by link_to under the hood)


  include Rails.application.routes.url_helpers
  default_url_options[:host] = 'localhost'

  # Token format is [[character-35]] or [[location-1]] etc, with the format:
  # [[<page_type>-<page_id>]].
  # todo page slugs could be cool for this? I dunno. We probably don't want to use a
  # field like name that can change ([[bob]]) or have an ambiguous link.
  TOKEN_REGEX = /\[\[([^\-]+)\-([^\]])+\]\]/

  # Only allow linking to content type classes
  # todo: we shouldn't have to map name here, but apparently rails is having a little difficulty
  # https://s3.amazonaws.com/raw.paste.esk.io/Llb%2F64DJHK?versionId=19Lb_TtukDbo1J_IoCpkr.d.pwpW_vmH
  VALID_LINK_CLASSES = Rails.application.config.content_types[:all].map(&:name)

  def self.show(text:, viewing_user: User.new)
    # We want to evaluate markdown first, because the markdown engine also happens
    # to strip out HTML tags. So: markdown, _then_ insert content links.
    formatted_text = markdown.render(text).html_safe

    substitute_content_links(formatted_text, viewing_user).html_safe
  end

  private

  def self.markdown
    # Returns a shared markdown rendering engine; use self.markdown.render(text)
    Rails.application.config.markdown
  end

  def self.substitute_content_links(text, viewing_user)
    tokens_to_replace(text).each do |token|
      text.gsub!(token[:matched_string], replacement_for_token(token, viewing_user))
    end

    text
  end

  def self.tokens_to_replace(text)
    matches = text.scan(TOKEN_REGEX).map do |klass, id|
      {
        content_type:   klass,
        content_id:     id,
        matched_string: "[[#{klass}-#{id}]]"
      }
    end
  end

  def self.replacement_for_token(token, viewing_user)
    return unknown_link_template(token) unless token.key?(:content_type) && token.key?(:content_id)

    content_class = token[:content_type].titleize.constantize
    return unknown_link_template(token) unless VALID_LINK_CLASSES.include?(content_class.name)

    content_id    = token[:content_id].to_i
    content_model = content_class.find_by(id: content_id)
    return unknown_link_template(token) unless content_model.present?

    if content_model.readable_by?(viewing_user)
      link_template(content_model)
    else
      private_link_template(content_model)
    end
  end

  def self.link_template(content_model)
    link_to(content_model.name, link_for(content_model), class: "content_link #{content_model.class}-link")
  end

  def self.private_link_template(content_model)
    link_to(content_model.name, '#', class: 'content_link disabled')
  end

  def self.unknown_link_template(attempted_key)
    link_to(attempted_key[:matched_string], '#', class: 'content_link disabled')
  end

  # This is a hack until I figure out how to include polymorphic paths in a service model.
  #todo remove this
  def self.link_for(content_model)
    [
      Rails.env.production? ? 'https://' : 'http://',
      Rails.application.routes.default_url_options[:host],
      '/plan/',
      content_model.class.name.downcase.pluralize,
      '/',
      content_model.id
    ].join
  end
end
