class DocumentRevisionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_document
  before_action :verify_document_ownership
  before_action :set_document_revision, only: [:show, :destroy, :diff, :restore]
  around_action :use_writers_time_zone

  REVISIONS_PER_PAGE = 60
  # The list's preview shows the start of each revision's text
  PREVIEW_CHARACTERS = 500

  # GET /document_revisions
  def index
    @document_revisions = @document.document_revisions
      # The list doesn't show the text itself (previews load when opened), so leave out the bodies
      .select(DocumentRevision.column_names.excluding('body').map { |column| "document_revisions.#{column}" })
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
    # A revision's updated_at is when its text was saved (see Document#keep_replaced_version!)
    @first_backup_at = @document.document_revisions.minimum(:updated_at)
    @newest_revision = @document.document_revisions.order(created_at: :desc, id: :desc).select(:id, :updated_at, :cached_word_count).first if params[:page].to_i <= 1
  end

  # GET /document_revisions/1
  # GET /document_revisions/1.txt: the start of the revision's text, for the list's preview
  def show
    respond_to do |format|
      format.html
      format.text do
        text = RevisionDiff.plain_text(@document_revision.body)
        render plain: text.length > PREVIEW_CHARACTERS ? "#{text[0, PREVIEW_CHARACTERS]}..." : text
      end
    end
  end

  # GET /document_revisions/1/diff: what changed between the revision before this one and this one
  def diff
    previous_revision = @document.document_revisions
      .where('created_at < ? OR (created_at = ? AND id < ?)', @document_revision.created_at, @document_revision.created_at, @document_revision.id)
      .order(created_at: :desc, id: :desc)
      .first

    if previous_revision
      render partial: 'diff', locals: { diff: RevisionDiff.new(previous_revision, @document_revision) }
    else
      render partial: 'first_revision', locals: { revision: @document_revision }
    end
  end

  # GET /document_revisions/current_diff: what has changed since the newest revision was kept
  def current_diff
    newest = @document.document_revisions.order(created_at: :desc, id: :desc).first
    return head :not_found if newest.nil?

    render partial: 'diff', locals: { diff: RevisionDiff.new(newest, @document) }
  end

  # POST /document_revisions/1/restore
  def restore
    restored_at = @document_revision.updated_at.strftime('%B %d, %Y at %I:%M %p')
    if @document.same_text_as?(@document_revision)
      return redirect_to edit_document_path(@document), notice: "Your document already matches the revision from #{restored_at}."
    end

    words_before = WordCountService.count(@document.body)
    words_after = WordCountService.count(@document_revision.body)

    # History only ever grows: the current text is kept first (unless the newest revision already
    # holds it), and the restored text becomes the current version.
    @document.keep_current_version!
    @document.update!(
      title: @document_revision.title,
      body: @document_revision.body,
      synopsis: @document_revision.synopsis,
      notes_text: @document_revision.notes_text,
      cached_word_count: words_after
    )

    # Bringing back old text isn't writing it
    @document.discount_restored_words!(words_after - words_before, word_count_now: words_after)

    redirect_to edit_document_path(@document), notice: "Document successfully restored to revision from #{restored_at}. Your previous version has been saved as a new revision."
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
