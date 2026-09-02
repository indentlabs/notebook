# Renders a page's cover image for one of the display shapes in
# ImagePresets, honouring the framing chosen in the gallery editor.
#
#   <%= content_image_tag(character, :card, class: 'w-full h-full object-cover') %>
#   <%= content_image_tag(universe, :banner, include_private: true, pick: :random) %>
#
# When a derivative cut to the writer's crop exists it is served directly.
# Otherwise the largest general-purpose size is served with a CSS
# object-position that keeps the writer's focal point in view. With no image
# at all, the content type's placeholder header is rendered.
module ContentImageHelper
  # Sizes to serve when a preset derivative has not been generated yet.
  FALLBACK_SIZE = { banner: :hero, card: :large, square: :medium }.freeze

  def content_image_tag(content, preset, include_private: false, pick: :first, **options)
    preset = preset.to_sym
    image  = content.respond_to?(:cover_image) ? content.cover_image(include_private: include_private, pick: pick) : nil

    if image.nil?
      options[:alt] ||= "#{content.try(:name)} placeholder image".strip
      return image_tag(content_placeholder_image(content), options)
    end

    options[:alt] ||= image.notes.presence || "#{content.try(:name)} #{preset}".strip
    options[:loading] = 'lazy' unless options.key?(:loading) || preset == :banner

    src = image.preset_url(preset)
    if src.nil?
      src = image.url(FALLBACK_SIZE.fetch(preset, :large)) || image.original_url
      options[:style] = [options[:style], "object-position: #{image.object_position}"].compact.join('; ')
    end

    return image_tag(content_placeholder_image(content), options.except(:style)) if src.nil?

    image_tag(src, options)
  end

  # Absolute URL for social previews (Open Graph / Twitter). Uses the card
  # framing at its full output size; falls back to the placeholder.
  def content_social_image_url(content)
    image = content.respond_to?(:cover_image) ? content.cover_image(include_private: false) : nil
    url = image && (image.preset_url(:card) || image.url(:hero) || image.original_url)
    url ||= content_placeholder_image(content)
    image_url(url)
  end

  def content_placeholder_image(content)
    klass = content.respond_to?(:page_type) && content.page_type.present? ? content.page_type : content.class.name
    "card-headers/#{klass.to_s.downcase.pluralize}.webp"
  end
end
