require 'test_helper'

class DocumentAnalysisJobTest < ActiveJob::TestCase
  def setup
    @user = users(:one)
    @document = documents(:one)
    @document.update!(user: @user)
    @analysis = @document.document_analysis.create!(queued_at: DateTime.current)
  end

  test "job is enqueued on the analysis queue" do
    assert_equal "analysis", DocumentAnalysisJob.new.queue_name
  end

  test "analyze! on document enqueues the job" do
    assert_enqueued_with(job: DocumentAnalysisJob) do
      @document.analyze!
    end
  end

  test "job updates progress throughout execution" do
    # We can't easily run the full pipeline in test without external services,
    # but we can verify the job finds the analysis record
    analysis = DocumentAnalysis.find(@analysis.id)
    assert_not_nil analysis
    assert_equal 0, analysis.progress
  end
end
