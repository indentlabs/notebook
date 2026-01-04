class DocumentRevisionsController < ApplicationController
  before_action :set_document, only: [:index, :show, :destroy, :diff, :restore]
  before_action :set_document_revision, only: [:show, :edit, :update, :destroy, :diff, :restore]

  # GET /document_revisions
  def index
    @document_revisions = @document.document_revisions.order('created_at DESC').paginate(page: params[:page], per_page: 60)
  end

  # GET /document_revisions/1
  def show
  end

  # GET /document_revisions/1/diff
  def diff
    require 'diffy'
    require 'nokogiri'
    
    # Find the previous revision for comparison
    previous_revision = @document.document_revisions
                                 .where("created_at < ?", @document_revision.created_at)
                                 .order(created_at: :desc)
                                 .first
    
    if previous_revision
      # Strip HTML and get clean text
      previous_html = previous_revision.body.to_s
      current_html = @document_revision.body.to_s
      
      previous_text = strip_and_clean_html(previous_html)
      current_text = strip_and_clean_html(current_html)
      
      # For very large documents, truncate to avoid memory issues
      max_length = 50_000  # ~10k words
      if previous_text.length > max_length || current_text.length > max_length
        diff_html = generate_author_friendly_diff(previous_text[0..max_length], current_text[0..max_length], truncated: true)
      else
        diff_html = generate_author_friendly_diff(previous_text, current_text)
      end
      
      render html: diff_html.html_safe
    else
      # This is the first revision, show a friendly message
      diff_html = generate_first_revision_view(strip_and_clean_html(@document_revision.body.to_s))
      render html: diff_html.html_safe
    end
  end


  # POST /document_revisions/1/restore
  def restore
    # First, create a backup revision of the current document state
    current_revision = @document.document_revisions.create!(
      title: @document.title,
      body: @document.body,
      synopsis: @document.synopsis,
      universe_id: @document.universe_id,
      notes_text: @document.notes_text,
      cached_word_count: @document.cached_word_count || 0
    )
    
    # Then restore the selected revision's content to the document
    @document.update!(
      title: @document_revision.title,
      body: @document_revision.body,
      synopsis: @document_revision.synopsis,
      notes_text: @document_revision.notes_text,
      cached_word_count: @document_revision.cached_word_count
    )
    
    redirect_to edit_document_path(@document), notice: "Document successfully restored to revision from #{@document_revision.created_at.strftime('%B %d, %Y at %I:%M %p')}. Your previous version has been saved as a new revision."
  rescue => e
    Rails.logger.error "Failed to restore revision #{@document_revision.id} for document #{@document.id}: #{e.message}"
    redirect_to document_document_revisions_path(@document), alert: 'Failed to restore revision. Please try again.'
  end
  
  def strip_and_clean_html(html_text)
    # Convert HTML to clean text, preserving paragraph breaks
    doc = Nokogiri::HTML(html_text)
    
    # Remove script and style elements
    doc.css('script, style').remove
    
    # Convert block elements to preserve structure
    # Add double newlines after paragraphs for clear separation
    doc.css('p').each { |p| p.after("\n\n") }
    doc.css('div').each { |div| div.after("\n") }
    doc.css('br').each { |br| br.replace("\n") }
    doc.css('h1, h2, h3, h4, h5, h6').each { |h| h.after("\n\n") }
    doc.css('blockquote').each { |bq| bq.after("\n\n") }
    
    # Get text and clean up whitespace while preserving paragraph structure
    text = doc.text
    text.gsub(/\r\n?/, "\n")           # Normalize line endings
        .gsub(/[ \t]+/, ' ')            # Collapse spaces and tabs (but NOT newlines)
        .gsub(/ *\n */, "\n")           # Remove spaces around newlines
        .gsub(/\n{3,}/, "\n\n")         # Reduce 3+ consecutive newlines to exactly 2
        .gsub(/\A\n+/, '')              # Remove leading newlines
        .gsub(/\n+\z/, '')              # Remove trailing newlines
        .strip
  end

  def generate_author_friendly_diff(previous_text, current_text, truncated: false)
    # Use diffy to get the diff directly on the text, preserving original formatting
    # This maintains newlines and text structure as the author intended
    diff = Diffy::Diff.new(previous_text, current_text, context: 3)
    
    # Calculate statistics
    prev_words = previous_text.split.size
    curr_words = current_text.split.size
    word_diff = curr_words - prev_words
    
    # Build the HTML
    html = <<~HTML
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <!-- Statistics Header -->
        <div class="mb-6 pb-4 border-b border-gray-200">
          <h3 class="text-lg font-semibold text-gray-900 mb-3">Changes Summary</h3>
          <div class="flex items-center space-x-6 text-sm">
            <div class="flex items-center">
              <div class="w-3 h-3 bg-green-500 rounded-full mr-2"></div>
              <span class="text-gray-600">
                <span class="font-semibold text-gray-900">#{word_diff > 0 ? '+' : ''}#{word_diff}</span> words
              </span>
            </div>
            <div class="text-gray-500">
              Previous: #{prev_words} words → Current: #{curr_words} words
            </div>
            #{truncated ? '<div class="text-amber-600 flex items-center"><i class="material-icons text-xs mr-1">warning</i>Document truncated for performance</div>' : ''}
          </div>
        </div>
        
        <!-- Side by Side Comparison -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <!-- Previous Version -->
          <div>
            <h4 class="text-sm font-semibold text-gray-700 mb-3 flex items-center">
              <i class="material-icons text-xs mr-2 text-gray-400">history</i>
              Previous Version
            </h4>
            <div class="prose prose-sm max-w-none bg-gray-50 rounded-lg p-4 min-h-[200px]">
              #{format_version_column(diff, :old, previous_text, current_text)}
            </div>
          </div>
          
          <!-- Current Version -->
          <div>
            <h4 class="text-sm font-semibold text-gray-700 mb-3 flex items-center">
              <i class="material-icons text-xs mr-2 text-green-600">check_circle</i>
              Current Version
            </h4>
            <div class="prose prose-sm max-w-none bg-green-50 rounded-lg p-4 min-h-[200px]">
              #{format_version_column(diff, :new, previous_text, current_text)}
            </div>
          </div>
        </div>
        
        <!-- Legend -->
        <div class="mt-6 pt-4 border-t border-gray-200">
          <div class="flex items-center space-x-6 text-xs text-gray-600">
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
              <span>Unchanged text</span>
            </div>
          </div>
        </div>
      </div>
    HTML
    
    html
  end
  
  def format_version_column(diff, version, previous_text, current_text)
    formatted_html = ""
    
    diff.to_s(:text).each_line do |line|
      next if line.start_with?('@')  # Skip line numbers
      next if line.strip == '\\ No newline at end of file'
      
      # Safely extract content, handling edge cases
      if line.length > 1
        content = CGI.escapeHTML(line[1..-1].chomp) # Remove diff marker and newline
        # Convert newlines to HTML line breaks for proper display
        content = content.gsub(/\n/, '<br>')
      else
        content = ""
      end
      
      # Get the diff marker (first character)
      marker = line[0] || ' '
      
      if version == :old
        # Show removed and unchanged content for old version
        case marker
        when '-'
          # Removed content - show in red with strikethrough
          formatted_html += "<p class='bg-red-100 text-red-900 px-2 py-1 rounded border-l-4 border-red-500 my-2'><del>#{content}</del></p>"
        when '+'
          # Added content - skip in old version
        when ' '
          # Context/unchanged content - show normally
          formatted_html += "<p class='text-gray-700 my-2'>#{content}</p>"
        else
          # Handle any other cases as context
          formatted_html += "<p class='text-gray-700 my-2'>#{content}</p>"
        end
      else # version == :new
        # Show added and unchanged content for new version
        case marker
        when '+'
          # Added content - show in green with bold
          formatted_html += "<p class='bg-green-100 text-green-900 px-2 py-1 rounded border-l-4 border-green-500 my-2'><strong>#{content}</strong></p>"
        when '-'
          # Removed content - skip in new version
        when ' '
          # Context/unchanged content - show normally
          formatted_html += "<p class='text-gray-700 my-2'>#{content}</p>"
        else
          # Handle any other cases as context
          formatted_html += "<p class='text-gray-700 my-2'>#{content}</p>"
        end
      end
    end
    
    if formatted_html.empty?
      # If no diff content, show the actual revision content without highlighting
      content = version == :old ? previous_text : current_text
      if content.blank?
        "<p class='text-gray-400 italic'>No content</p>"
      else
        # Show the plain text content without diff highlighting
        paragraphs = content.split(/\n\n+/).map(&:strip).reject(&:empty?)
        paragraphs.map { |para| "<p class='text-gray-700 my-2'>#{CGI.escapeHTML(para)}</p>" }.join
      end
    else
      formatted_html
    end
  end
  
  def generate_first_revision_view(text)
    word_count = text.split.size
    preview = text[0..500]
    preview += "..." if text.length > 500
    
    <<~HTML
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div class="text-center py-8">
          <i class="material-icons text-green-500 text-5xl mb-4">celebration</i>
          <h3 class="text-xl font-semibold text-gray-900 mb-2">First Revision Created!</h3>
          <p class="text-gray-600 mb-6">This is the initial version of your document.</p>
          
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

  # GET /document_revisions/new
  def new
    @document_revision = DocumentRevision.new
  end

  # GET /document_revisions/1/edit
  def edit
  end

  # POST /document_revisions
  def create
    @document_revision = DocumentRevision.new(document_revision_params)

    if @document_revision.save
      redirect_to @document_revision, notice: 'Document revision was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /document_revisions/1
  def update
    if @document_revision.update(document_revision_params)
      redirect_to @document_revision, notice: 'Document revision was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /document_revisions/1
  def destroy
    @document_revision.destroy
    redirect_to document_document_revisions_path(@document), notice: 'Document revision was successfully deleted.'
  end

  private

  def set_document
    @document = Document.find(params[:document_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_document_revision
    @document_revision = DocumentRevision.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def document_revision_params
    params.fetch(:document_revision, {})
  end
end
