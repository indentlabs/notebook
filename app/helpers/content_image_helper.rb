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
  # Options:
  #   include_private: show private uploads (owner / collaborator views)
  #   pick:            :first or :random when no cover is chosen
  #   size:            :full (default) or :small for boxes of about 100 px or
  #                    less, where the preset has a reduced derivative
  #   sizes:           the HTML sizes attribute for the banner's srcset
  #                    (default "100vw")
  def content_image_tag(content, preset, include_private: false, pick: :first, size: :full, sizes: nil, **options)
    preset = preset.to_sym
    image  = content.respond_to?(:cover_image) ? content.cover_image(include_private: include_private, pick: pick, preset: preset) : nil

    if image.nil?
      options[:alt] ||= "#{content.try(:name)} placeholder image".strip
      return image_tag(content_placeholder_image(content), options)
    end

    options[:alt] ||= image.notes.presence || "#{content.try(:name)} #{preset}".strip
    options[:loading] = 'lazy' unless options.key?(:loading) || preset == :banner
    options[:decoding] ||= 'async'

    src = image.preset_url(preset, size: size)
    if src
      dimensions = image.preset_dimensions(preset, size: size)
      options[:width]  ||= dimensions[0]
      options[:height] ||= dimensions[1]

      small_url = size.to_sym == :full ? image.preset_url(preset, size: :small) : nil
      if small_url && small_url != src
        small_dimensions = image.preset_dimensions(preset, size: :small)
        options[:srcset] ||= "#{small_url} #{small_dimensions[0]}w, #{src} #{dimensions[0]}w"
        options[:sizes]  ||= sizes || (preset == :banner ? '100vw' : "#{dimensions[0]}px")
      end
    else
      src = image.url(ImagePresets.fallback_size(preset)) || image.original_url
      options[:style] = [options[:style], "object-position: #{image.object_position}"].compact.join('; ')
    end

    return image_tag(content_placeholder_image(content), options.except(:style, :width, :height, :srcset, :sizes)) if src.nil?

    image_tag(src, options)
  end

  # Renders the hero header banner for a page.
  # If the cover image is narrow (e.g. portrait or square) and lacks an explicit
  # custom banner crop, it renders an ambient blurred backdrop behind the crisp,
  # uncropped contained image. If the image is wide, has an explicit custom banner
  # crop, or falls back to a placeholder, it renders full-bleed.
  def content_hero_banner_tag(content, include_private: false, pick: :first, **options)
    image = content.respond_to?(:cover_image) ? content.cover_image(include_private: include_private, pick: pick, preset: :banner) : nil
    options[:class] = [options[:class], 'w-full h-full object-cover'].compact.join(' ')

    if image.nil?
      options[:alt] ||= "#{content.try(:name)} placeholder image".strip
      return image_tag(content_placeholder_image(content), options)
    end

    options[:alt] ||= image.notes.presence || "#{content.try(:name)} banner image".strip

    # If the image has an explicit custom banner crop or is naturally wide
    # (ContentImage::FULL_BLEED_BANNER_RATIO), render edge-to-edge full-bleed using the
    # standard preset derivative or focal point fallback. content_image_tag also
    # handles images without a usable URL.
    display_src = image.display_url
    if display_src.nil? || image.custom_crop?(:banner) || image.wide?
      return content_image_tag(content, :banner, include_private: include_private, pick: pick, **options)
    end

    # Otherwise (portrait, square, or standard 4:3 photo without a custom banner crop):
    # Render ambient blurred background + crisp centered uncropped foreground.
    bg_img = image_tag(display_src,
      class: 'w-full h-full object-cover blur-2xl scale-110 opacity-50 brightness-75 select-none pointer-events-none',
      alt: '',
      aria: { hidden: 'true' },
      loading: 'eager',
      decoding: 'async'
    )

    fg_img = image_tag(display_src,
      class: 'max-h-full max-w-full object-contain drop-shadow-2xl select-none',
      alt: options[:alt],
      loading: 'eager',
      decoding: 'async'
    )

    content_tag(:div, class: 'absolute inset-0 overflow-hidden select-none pointer-events-none', aria: { hidden: 'true' }) { bg_img } +
      content_tag(:div, class: 'relative w-full h-full flex items-center justify-center p-2 sm:p-4') { fg_img }
  end

  # Absolute URL for social previews (Open Graph / Twitter): the 1200x630
  # link-preview framing, else the card, else a general size, else the
  # placeholder.
  def content_social_image_url(content)
    image = content.respond_to?(:cover_image) ? content.cover_image(include_private: false, preset: :social) : nil
    url = image && (image.preset_url(:social) || image.preset_url(:card) || image.url(:hero) || image.original_url)
    url ||= content_placeholder_image(content)
    image_url(url)
  end

  # Meta-tags options for a page's social preview. Merge into set_meta_tags.
  def content_social_meta(content)
    url = content_social_image_url(content)
    size = ImagePresets[:social].size
    {
      image_src: url,
      og:        { type: 'website', image: { _: url, width: size[0], height: size[1] } },
      twitter:   { card: 'summary_large_image', image: url }
    }
  end

  def content_placeholder_image(content)
    klass = content.respond_to?(:page_type) && content.page_type.present? ? content.page_type : content.class.name
    "card-headers/#{klass.to_s.downcase.pluralize}.webp"
  end
end
