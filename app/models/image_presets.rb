# The display shapes a gallery image can be framed for.
#
# Every place on the site that shows a page's image uses one of these
# presets (see docs/gallery_ux_plan.md for the catalogue), so a writer only
# has to frame each image a few times rather than once per screen.
#
#   ImagePresets[:banner].ratio_label  # => "3:1"
#   ImagePresets[:card].size           # => [900, 600]
#   ImagePresets.keys                  # => [:banner, :card, :square, :social]
module ImagePresets
  Preset = Struct.new(:key, :label, :chip, :ratio, :size, :small_size, :description, keyword_init: true) do
    # Width divided by height.
    def aspect
      ratio[0].to_f / ratio[1]
    end

    def ratio_label
      "#{ratio[0]}:#{ratio[1]}"
    end

    # Paperclip geometry string for a centre-cropped derivative.
    def geometry(dimensions = size)
      "#{dimensions[0]}x#{dimensions[1]}#"
    end

    # Name of the reduced-size Paperclip style, when the preset has one.
    def small_style
      small_size ? :"#{key}_sm" : nil
    end

    # Paperclip style definitions for this preset: the full-size derivative
    # and, when small_size is set, a reduced one. Both are cut by the Cropper
    # processor from the writer's framing and written as WebP.
    def paperclip_styles
      styles = { key => ImagePresets.webp_style(geometry, processors: [:cropper], preset: key) }
      styles[small_style] = ImagePresets.webp_style(geometry(small_size), processors: [:cropper], preset: key) if small_size
      styles
    end

    def to_h
      {
        key:         key.to_s,
        label:       label,
        chip:        chip,
        ratio:       ratio,
        aspect:      aspect,
        size:        size,
        description: description
      }
    end
  end

  ALL = {
    banner: Preset.new(
      key:         :banner,
      label:       'Banner',
      chip:        'Banner',
      ratio:       [3, 1],
      size:        [1500, 500],
      small_size:  [750, 250],
      description: 'The wide strip across the top of the page'
    ),
    card: Preset.new(
      key:         :card,
      label:       'Card',
      chip:        'Card',
      ratio:       [3, 2],
      size:        [900, 600],
      description: 'Cards in lists, dashboards and link previews'
    ),
    square: Preset.new(
      key:         :square,
      label:       'Square',
      chip:        'Thumbnail',
      ratio:       [1, 1],
      size:        [600, 600],
      small_size:  [200, 200],
      description: 'Thumbnails, avatars and the page sidebar'
    ),
    social: Preset.new(
      key:         :social,
      label:       'Link preview',
      chip:        'Link preview',
      ratio:       [40, 21],
      size:        [1200, 630],
      description: 'The image shown when this page is shared on social networks and chat apps'
    )
  }.freeze

  def self.[](key)
    ALL[key.to_s.to_sym]
  end

  def self.keys
    ALL.keys
  end

  def self.each(&block)
    ALL.values.each(&block)
  end

  def self.valid?(key)
    ALL.key?(key.to_s.to_sym)
  end

  # Legacy Paperclip style to serve when a preset derivative does not exist yet.
  FALLBACK_SIZES = { banner: :hero, card: :large, square: :medium, social: :hero }.freeze

  def self.fallback_size(preset)
    FALLBACK_SIZES.fetch(preset.to_s.to_sym, :large)
  end

  # ImageMagick options shared by every WebP derivative.
  WEBP_CONVERT_OPTIONS = '-quality 82 -strip'.freeze

  def self.webp_style(geometry, **extra)
    { geometry: geometry, format: :webp, convert_options: WEBP_CONVERT_OPTIONS }.merge(extra)
  end

  # Every crop-shaped Paperclip style (full and small sizes for all presets).
  def self.paperclip_styles
    ALL.values.each_with_object({}) { |preset, styles| styles.merge!(preset.paperclip_styles) }
  end

  # Names of the styles regenerated when an image's framing changes.
  def self.style_names
    paperclip_styles.keys
  end

  # Serialisable description of every preset, for the editor's JavaScript.
  def self.as_json(*)
    ALL.values.map(&:to_h)
  end
end
