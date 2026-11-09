require 'diffy'

# What changed between two versions of a document, for the revision history's "Show Changes".
# The markup is in app/views/document_revisions/_diff.html.erb.
class RevisionDiff
  # Diffing whole novels is fast; rendering every changed paragraph of a full rewrite isn't useful.
  # Removed and added paragraphs are capped separately, so a huge deletion can't crowd out what was added.
  MAX_CHANGED_PARAGRAPHS = 400

  Line = Struct.new(:kind, :text) # kind: :removed, :added, :unchanged or :gap

  attr_reader :previous_words, :current_words, :old_lines, :new_lines, :removed, :added

  def initialize(previous_version, current_version)
    @previous_version = previous_version
    @current_version = current_version
    @previous_words = WordCountService.count(previous_version.body)
    @current_words = WordCountService.count(current_version.body)
    @old_lines = []
    @new_lines = []
    @removed = 0
    @added = 0
    @truncated = false

    previous_text = self.class.plain_text(previous_version.body)
    current_text = self.class.plain_text(current_version.body)
    @text_changed = previous_text != current_text
    split_into_columns(previous_text, current_text) if @text_changed
  end

  def word_change
    current_words - previous_words
  end

  def text_changed?
    @text_changed
  end

  def truncated?
    @truncated
  end

  # What changed when the text didn't: e.g. ["Title", "Notes"], or ["Formatting"]
  def other_changes
    changed = { title: 'Title', synopsis: 'Synopsis', notes_text: 'Notes' }.select do |field, _label|
      @previous_version.public_send(field).to_s != @current_version.public_send(field).to_s
    end.values
    changed.presence || ['Formatting']
  end

  # The text of an HTML body, one paragraph per line with blank lines between them, so the diff
  # compares paragraphs. Non-breaking spaces become plain spaces, so swapping one for the other
  # isn't shown as a change.
  def self.plain_text(html)
    doc = Nokogiri::HTML(html.to_s)
    doc.css('script, style').remove
    doc.css('p, h1, h2, h3, h4, h5, h6, blockquote').each { |block| block.after("\n\n") }
    doc.css('div, li, tr').each { |block| block.after("\n") }
    doc.css('td, th').each { |cell| cell.after(' ') }
    doc.css('br').each { |br| br.replace("\n") }

    doc.text
       .tr(" ", ' ')
       .gsub(/\r\n?/, "\n")
       .gsub(/[ \t]+/, ' ')
       .gsub(/ *\n */, "\n")
       .gsub(/\n{3,}/, "\n\n")
       .strip
  end

  private

  def split_into_columns(previous_text, current_text)
    # Both texts end in a newline, so adding a paragraph at the end doesn't also show the old last
    # paragraph as removed and re-added. The whole texts are compared: cutting them short hid
    # anything written past the cut and showed old text near it as new.
    diff = Diffy::Diff.new(previous_text + "\n", current_text + "\n", context: 3, include_diff_info: true)

    # The first two lines name the temporary files diff compared ("--- /tmp/..." and "+++ /tmp/...")
    diff.to_s(:text).lines.drop(2).each do |line|
      if line.start_with?('@@')
        # A gap between changed parts of the document
        add_to_both(Line.new(:gap, nil)) unless truncated? || (old_lines.empty? && new_lines.empty?)
        next
      end

      text = line[1..].to_s.chomp
      next if text.strip.empty?

      case line[0]
      when '-'
        @removed += 1
        removed <= MAX_CHANGED_PARAGRAPHS ? old_lines << Line.new(:removed, text) : @truncated = true
      when '+'
        @added += 1
        added <= MAX_CHANGED_PARAGRAPHS ? new_lines << Line.new(:added, text) : @truncated = true
      else
        add_to_both(Line.new(:unchanged, text)) unless truncated?
      end
    end
  end

  def add_to_both(line)
    old_lines << line
    new_lines << line
  end
end
