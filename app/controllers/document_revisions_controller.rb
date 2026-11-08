class DocumentRevisionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_document
  before_action :verify_document_ownership
  before_action :set_document_revision, only: [:show, :destroy, :diff, :restore]
  around_action :use_writers_time_zone

  REVISIONS_PER_PAGE = 60
  # The list shows the start of each revision, so it only loads that much of each body
  PREVIEW_CHARACTERS = 2_000

  # Diffing whole novels is fast; rendering every changed paragraph of a full rewrite isn't useful
  MAX_DIFF_LINES_SHOWN = 400

  # GET /document_revisions
  def index
    @document_revisions = @document.document_revisions
      .select(DocumentRevision.column_names.excluding('body').map { |column| "document_revisions.#{column}" })
      .select("SUBSTR(document_revisions.body, 1, #{PREVIEW_CHARACTERS}) AS body_preview")
      .order(created_at: :desc, id: :desc)
      .paginate(page: params[:page], per_page: REVISIONS_PER_PAGE)
    @revisions_on_page = @document_revisions.to_a

    # The last revision on a page is compared with the first one on the next page
    if (oldest_on_page = @revisions_on_page.last)
      @revision_before_page = @document.document_revisions
        .where('created_at < ? OR (created_at = ? AND id < ?)', oldest_on_page.created_at, oldest_on_page.created_at, oldest_on_page.id)
        .order(created_at: :desc, id: :desc)
        .select(:id, :created_at, :cached_word_count)
        .first
    end

    @revision_count = @document_revisions.total_entries
    @first_backup_at = @document.document_revisions.minimum(:created_at)
  end

  # GET /document_revisions/1
  def show
  end

  # GET /document_revisions/1/diff
  def diff
    require 'diffy'

    # Find the previous revision for comparison
    previous_revision = @document.document_revisions
      .where('created_at < ? OR (created_at = ? AND id < ?)', @document_revision.created_at, @document_revision.created_at, @document_revision.id)
      .order(created_at: :desc, id: :desc)
      .first

    diff_html = if previous_revision
      generate_author_friendly_diff(previous_revision, @document_revision)
    else
      # This is the first revision, show a friendly message
      generate_first_revision_view(@document_revision)
    end

    render html: diff_html.html_safe
  end

  # POST /document_revisions/1/restore
  def restore
    words_before = WordCountService.count_with_fallback(@document.body)

    # Keep the current text in the history, unless the newest revision already holds it
    latest = @document.document_revisions.order(created_at: :desc, id: :desc).first
    unless latest && same_text?(latest, @document)
      @document.document_revisions.create!(revision_attributes_from(@document, cached_word_count: words_before))
    end

    @document.update!(
      title: @document_revision.title,
      body: @document_revision.body,
      synopsis: @document_revision.synopsis,
      notes_text: @document_revision.notes_text
    )
    words_after = WordCountService.count_with_fallback(@document.body)
    @document.update_column(:cached_word_count, words_after)

    # The restored text gets its own entry at the top of the history. SaveDocumentRevisionJob keeps
    # the newest revision up to date, so this is the one it updates, not the backup above.
    @document.document_revisions.create!(revision_attributes_from(@document, cached_word_count: words_after))

    # Bringing back old text isn't writing it
    @document.discount_restored_words!(words_after - words_before)

    redirect_to edit_document_path(@document), notice: "Document successfully restored to revision from #{@document_revision.updated_at.strftime('%B %d, %Y at %I:%M %p')}. Your previous version has been saved as a new revision."
  rescue => e
    Rails.logger.error "Failed to restore revision #{@document_revision.id} for document #{@document.id}: #{e.message}"
    redirect_to document_document_revisions_path(@document), alert: 'Failed to restore revision. Please try again.'
  end

  # DELETE /document_revisions/1
  def destroy
    @document_revision.destroy
    redirect_to document_document_revisions_path(@document), notice: 'Document revision was successfully deleted.'
  end

  private

  # Revision times are shown in the writer's time zone, the same one their daily word counts use
  def use_writers_time_zone(&block)
    zone = Time.find_zone(current_user&.time_zone.presence) || Time.find_zone('UTC')
    Time.use_zone(zone, &block)
  end

  def revision_attributes_from(document, cached_word_count:)
    {
      title:             document.title,
      body:              document.body,
      synopsis:          document.synopsis,
      universe_id:       document.universe_id,
      notes_text:        document.notes_text,
      cached_word_count: cached_word_count
    }
  end

  def same_text?(revision, document)
    %i[title body synopsis notes_text].all? { |field| revision.public_send(field).to_s == document.public_send(field).to_s }
  end

  def strip_and_clean_html(html_text)
    # Convert HTML to clean text, preserving paragraph breaks
    doc = Nokogiri::HTML(html_text)

    # Remove script and style elements
    doc.css('script, style').remove

    # Convert block elements to preserve structure
    # Add double newlines after paragraphs for clear separation
    doc.css('p').each { |p| p.after("\n\n") }
    doc.css('div, li, tr').each { |block| block.after("\n") }
    doc.css('td, th').each { |cell| cell.after(' ') }
    doc.css('br').each { |br| br.replace("\n") }
    doc.css('h1, h2, h3, h4, h5, h6').each { |h| h.after("\n\n") }
    doc.css('blockquote').each { |bq| bq.after("\n\n") }

    # Get text and clean up whitespace while preserving paragraph structure.
    # Non-breaking spaces become plain spaces, so swapping one for the other isn't shown as a change.
    text = doc.text
    text.tr("\u00A0", ' ')
        .gsub(/\r\n?/, "\n")           # Normalize line endings
        .gsub(/[ \t]+/, ' ')            # Collapse spaces and tabs (but NOT newlines)
        .gsub(/ *\n */, "\n")           # Remove spaces around newlines
        .gsub(/\n{3,}/, "\n\n")         # Reduce 3+ consecutive newlines to exactly 2
        .gsub(/\A\n+/, '')              # Remove leading newlines
        .gsub(/\n+\z/, '')              # Remove trailing newlines
        .strip
  end

  def generate_author_friendly_diff(previous_revision, current_revision)
    previous_text = strip_and_clean_html(previous_revision.body.to_s)
    current_text  = strip_and_clean_html(current_revision.body.to_s)

    prev_words = WordCountService.count(previous_revision.body)
    curr_words = WordCountService.count(current_revision.body)
    word_diff = curr_words - prev_words

    if previous_text == current_text
      columns = nil
    else
      # Both texts end in a newline, so adding a paragraph at the end doesn't also show the old last
      # paragraph as removed and re-added. The whole texts are compared: cutting them short hid
      # anything written past the cut and showed old text near it as new.
      diff = Diffy::Diff.new(previous_text + "\n", current_text + "\n", context: 3)
      columns = diff_columns(diff.to_s(:text).lines)
    end

    <<~HTML
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 dark:bg-gray-800 dark:border-gray-700">
        <!-- Statistics Header -->
        <div class="mb-6 pb-4 border-b border-gray-200 dark:border-gray-700">
          <h3 class="text-lg font-semibold text-gray-900 mb-3 dark:text-white">Changes Summary</h3>
          <div class="flex flex-wrap items-center gap-x-6 gap-y-2 text-sm">
            <div class="flex items-center">
              <div class="w-3 h-3 bg-green-500 rounded-full mr-2"></div>
              <span class="text-gray-600 dark:text-gray-400">
                <span class="font-semibold text-gray-900 dark:text-white">#{word_diff > 0 ? '+' : ''}#{word_diff}</span> words
              </span>
            </div>
            <div class="text-gray-500 dark:text-gray-400">
              Previous: #{prev_words} words → This version: #{curr_words} words
            </div>
            #{columns&.dig(:truncated) ? '<div class="text-amber-600 flex items-center"><i class="material-icons text-xs mr-1">warning</i>Showing the first ' + MAX_DIFF_LINES_SHOWN.to_s + ' changed paragraphs</div>' : ''}
          </div>
        </div>

        #{columns ? side_by_side_html(columns) : unchanged_text_html(previous_revision, current_revision)}
      </div>
    HTML
  end

  # Splits Diffy's unified text diff into the two columns of the side-by-side view.
  def diff_columns(diff_lines)
    old_column = []
    new_column = []
    shown = 0
    truncated = false

    diff_lines.each do |line|
      if line.start_with?('@@')
        # A gap between changed parts of the document
        unless old_column.empty? && new_column.empty?
          old_column << "<p class='text-center text-gray-400 my-2'>⋯</p>"
          new_column << "<p class='text-center text-gray-400 my-2'>⋯</p>"
        end
        next
      end
      next if line.start_with?('\\')

      content = line[1..].to_s.chomp
      next if content.strip.empty?

      if shown >= MAX_DIFF_LINES_SHOWN
        truncated = true
        break
      end
      shown += 1

      escaped = CGI.escapeHTML(content)
      case line[0]
      when '-'
        old_column << "<p class='bg-red-100 text-red-900 px-2 py-1 rounded border-l-4 border-red-500 my-2'><del>#{escaped}</del></p>"
      when '+'
        new_column << "<p class='bg-green-100 text-green-900 px-2 py-1 rounded border-l-4 border-green-500 my-2'><strong>#{escaped}</strong></p>"
      else
        old_column << "<p class='text-gray-700 my-2 dark:text-gray-300'>#{escaped}</p>"
        new_column << "<p class='text-gray-700 my-2 dark:text-gray-300'>#{escaped}</p>"
      end
    end

    { old: old_column.join, new: new_column.join, truncated: truncated }
  end

  def side_by_side_html(columns)
    <<~HTML
      <!-- Side by Side Comparison -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Previous Version -->
        <div>
          <h4 class="text-sm font-semibold text-gray-700 mb-3 flex items-center dark:text-gray-300">
            <i class="material-icons text-xs mr-2 text-gray-400">history</i>
            Previous Version
          </h4>
          <div class="prose prose-sm max-w-none bg-gray-50 rounded-lg p-4 dark:bg-gray-900">
            #{columns[:old].presence || "<p class='text-gray-400 italic'>Nothing removed</p>"}
          </div>
        </div>

        <!-- This Version -->
        <div>
          <h4 class="text-sm font-semibold text-gray-700 mb-3 flex items-center dark:text-gray-300">
            <i class="material-icons text-xs mr-2 text-green-600">check_circle</i>
            This Version
          </h4>
          <div class="prose prose-sm max-w-none bg-green-50 rounded-lg p-4 dark:bg-gray-900">
            #{columns[:new].presence || "<p class='text-gray-400 italic'>Nothing added</p>"}
          </div>
        </div>
      </div>

      <!-- Legend -->
      <div class="mt-6 pt-4 border-t border-gray-200 dark:border-gray-700">
        <div class="flex flex-wrap items-center gap-x-6 gap-y-2 text-xs text-gray-600 dark:text-gray-400">
          <div class="flex items-center">
            <span class="inline-block w-12 h-3 bg-red-100 border border-red-300 rounded mr-2"></span>
            <span>Removed text</span>
          </div>
          <div class="flex items-center">
            <span class="inline-block w-12 h-3 bg-green-100 border border-green-300 rounded mr-2"></span>
            <span>Added text</span>
          </div>
          <div class="flex items-center">
            <span class="inline-block w-12 h-3 bg-gray-100 border border-gray-300 rounded mr-2"></span>
            <span>Unchanged text around the changes</span>
          </div>
        </div>
      </div>
    HTML
  end

  # A revision whose text matches the one before it (only the title, synopsis, notes or formatting changed)
  def unchanged_text_html(previous_revision, current_revision)
    changed = { title: 'Title', synopsis: 'Synopsis', notes_text: 'Notes' }.select do |field, _label|
      previous_revision.public_send(field).to_s != current_revision.public_send(field).to_s
    end.values
    changed << 'Formatting' if changed.empty?

    <<~HTML
      <p class="text-sm text-gray-600 dark:text-gray-400">
        The text didn't change in this version. Changed: #{CGI.escapeHTML(changed.to_sentence)}.
      </p>
    HTML
  end

  def generate_first_revision_view(revision)
    text = strip_and_clean_html(revision.body.to_s)
    word_count = WordCountService.count(revision.body)
    preview = text[0..500]
    preview += "..." if text.length > 500

    <<~HTML
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 dark:bg-gray-800 dark:border-gray-700">
        <div class="text-center py-8">
          <i class="material-icons text-green-500 text-5xl mb-4">celebration</i>
          <h3 class="text-xl font-semibold text-gray-900 mb-2 dark:text-white">First Revision Created!</h3>
          <p class="text-gray-600 mb-6 dark:text-gray-400">This is the initial version of your document.</p>

          <div class="bg-green-50 border border-green-200 rounded-lg p-4 max-w-2xl mx-auto text-left">
            <div class="flex items-center justify-between mb-3">
              <span class="text-sm font-semibold text-green-800">Document Preview</span>
              <span class="text-xs text-green-600">#{word_count} words</span>
            </div>
            <div class="prose prose-sm text-gray-700">
              <p>#{CGI.escapeHTML(preview)}</p>
            </div>
          </div>

          <p class="text-xs text-gray-500 mt-6">
            Future changes to your document will be tracked and displayed here.
          </p>
        </div>
      </div>
    HTML
  end

  def set_document
    @document = Document.find(params[:document_id])
  end

  # Revisions can hold drafts the author never published, so they stay with the author
  # even when the current version of the document is public.
  def verify_document_ownership
    return if @document.updatable_by?(current_user)

    redirect_to(root_path, notice: "That document either doesn't exist or you don't have permission to view it.", status: :not_found)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_document_revision
    @document_revision = @document.document_revisions.find(params[:id])
  end
end
