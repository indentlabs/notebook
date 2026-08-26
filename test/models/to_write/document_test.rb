require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @document = documents(:one)
    @document.user = @user
    @document.save!
  end

  # -- Associations --

  test "belongs to user" do
    assert_respond_to @document, :user
    assert_equal @user, @document.user
  end

  test "has many document_analysis" do
    assert_respond_to @document, :document_analysis
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @document.document_analysis
  end

  test "has many document_revisions" do
    assert_respond_to @document, :document_revisions
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @document.document_revisions
  end

  test "has many document_entities through document_analysis" do
    assert_respond_to @document, :document_entities
  end

  test "has many document_concepts through document_analysis" do
    assert_respond_to @document, :document_concepts
  end

  test "has many document_categories through document_analysis" do
    assert_respond_to @document, :document_categories
  end

  test "destroying document destroys associated analyses" do
    analysis = @document.document_analysis.first
    assert analysis.present?, "expected fixture analysis to exist"

    assert_difference('DocumentAnalysis.count', -@document.document_analysis.count) do
      @document.destroy
    end
  end

  test "destroying document destroys associated revisions" do
    assert @document.document_revisions.count > 0, "expected fixture revisions to exist"

    assert_difference('DocumentRevision.count', -@document.document_revisions.count) do
      @document.destroy
    end
  end

  # -- Status enum --

  test "status enum defines expected values" do
    expected = %w[idea draft writing revising editing submitting published complete]
    assert_equal expected, Document.statuses.keys
  end

  test "status defaults to idea" do
    doc = Document.new
    assert_equal "idea", doc.status
  end

  test "status can be set via string" do
    @document.status = "writing"
    assert @document.writing?
  end

  test "status_options returns paired arrays for select dropdowns" do
    options = Document.status_options
    assert_kind_of Array, options
    assert_equal 8, options.length
    assert_equal ['Idea', 'idea'], options.first
    assert_equal ['Complete', 'complete'], options.last
  end

  # -- Archive functionality --

  test "archive! sets archived_at" do
    assert_nil @document.archived_at
    @document.archive!
    assert_not_nil @document.reload.archived_at
  end

  test "unarchive! clears archived_at" do
    @document.archive!
    @document.unarchive!
    assert_nil @document.reload.archived_at
  end

  test "archived? returns correct boolean" do
    assert_not @document.archived?
    @document.archive!
    assert @document.archived?
  end

  test "unarchived scope excludes archived documents" do
    @document.archive!
    assert_not_includes Document.unarchived, @document
  end

  test "archived scope includes only archived documents" do
    @document.archive!
    assert_includes Document.archived, @document
    assert_not_includes Document.archived, documents(:two)
  end

  # -- Display helpers --

  test "color returns expected class string" do
    assert_equal 'teal bg-teal-500', Document.color
    assert_equal 'teal bg-teal-500', @document.color
  end

  test "text_color returns expected class string" do
    assert_equal 'teal-text text-teal-500', Document.text_color
    assert_equal 'teal-text text-teal-500', @document.text_color
  end

  test "hex_color returns teal hex code" do
    assert_equal '#009688', Document.hex_color
  end

  test "icon returns description" do
    assert_equal 'description', Document.icon
    assert_equal 'description', @document.icon
  end

  test "page_type returns Document" do
    assert_equal 'Document', @document.page_type
  end

  # -- Name/description delegates --

  test "name returns title" do
    assert_equal @document.title, @document.name
  end

  test "description returns body" do
    assert_equal @document.body, @document.description
  end

  # -- Word count --

  test "word_count returns cached_word_count or 0" do
    @document.cached_word_count = 42
    assert_equal 42, @document.word_count

    @document.cached_word_count = nil
    assert_equal 0, @document.word_count
  end

  test "computed_word_count returns 0 for nil body" do
    @document.body = nil
    assert_equal 0, @document.computed_word_count
  end

  test "computed_word_count returns 0 for blank body" do
    @document.body = ""
    assert_equal 0, @document.computed_word_count
  end

  # -- Reading estimate --

  test "reading_estimate produces human-readable string" do
    @document.cached_word_count = 400
    assert_equal "~3 minute read", @document.reading_estimate

    @document.cached_word_count = 0
    assert_equal "~1 minute read", @document.reading_estimate
  end

  # -- Analyze! --

  test "analyze! creates a new document analysis and enqueues job" do
    assert_difference('DocumentAnalysis.count', 1) do
      @document.analyze!
    end

    analysis = @document.document_analysis.order(:created_at).last
    assert_not_nil analysis.queued_at
    assert_enqueued_with(job: DocumentAnalysisJob, args: [analysis.id])
  end

  # -- Save document revision --

  test "save_document_revision! is triggered on relevant field changes" do
    assert_enqueued_with(job: SaveDocumentRevisionJob) do
      @document.update!(title: "A brand new title")
    end
  end

  test "save_document_revision! is not triggered for irrelevant field changes" do
    # privacy is not in KEYS_TO_TRIGGER_REVISION_ON_CHANGE
    assert_no_enqueued_jobs(only: SaveDocumentRevisionJob) do
      @document.update!(privacy: "public")
    end
  end

  # -- Soft delete (acts_as_paranoid) --

  test "acts_as_paranoid soft deletes the record" do
    @document.destroy
    assert_not_nil @document.reload.deleted_at
    assert_nil Document.find_by(id: @document.id)
    assert Document.with_deleted.find(@document.id).present?
  end

  # -- KEYS_TO_TRIGGER_REVISION_ON_CHANGE --

  test "revision trigger keys include expected fields" do
    expected = %w(title body synopsis notes_text)
    assert_equal expected, Document::KEYS_TO_TRIGGER_REVISION_ON_CHANGE
  end
end
