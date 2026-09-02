# The display shapes a gallery image can be framed for.
#
# Every place on the site that shows a page's image uses one of these
# presets (see docs/gallery_ux_plan.md for the catalogue), so a writer only
# has to frame each image a few times rather than once per screen.
#
#   ImagePresets[:banner].ratio_label  # => "3:1"
#   ImagePresets[:card].size           # => [900, 600]
#   ImagePresets.keys                  # => [:banner, :card, :square]
module ImagePresets
  Preset = Struct.new(:key, :label, :ratio, :size, :description, keyword_init: true) do
    # Width divided by height.
    def aspect
      ratio[0].to_f / ratio[1]
    end

    def ratio_label
      "#{ratio[0]}:#{ratio[1]}"
    end

    # Paperclip geometry string for a centre-cropped derivative.
    def geometry
      "#{size[0]}x#{size[1]}#"
    end

    def to_h
      {
        key:         key.to_s,
        label:       label,
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
      ratio:       [3, 1],
      size:        [1500, 500],
      description: 'The wide strip across the top of the page'
    ),
    card: Preset.new(
      key:         :card,
      label:       'Card',
      ratio:       [3, 2],
      size:        [900, 600],
      description: 'Cards in lists, dashboards and link previews'
    ),
    square: Preset.new(
      key:         :square,
      label:       'Square',
      ratio:       [1, 1],
      size:        [600, 600],
      description: 'Thumbnails, avatars and the page sidebar'
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

  # Serialisable description of every preset, for the editor's JavaScript.
  def self.as_json(*)
    ALL.values.map(&:to_h)
  end
end
