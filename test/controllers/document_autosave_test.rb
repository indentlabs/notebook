require 'test_helper'
require 'minitest/mock'

class DocumentAutosaveTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  setup do
    @user = users(:one)
    @document = Document.create!(title: 'Draft', body: '<p>Once upon a time.</p>', user: @user)
    sign_in @user
  end

  test "saving a changed body queues a revision job" do
    assert_enqueued_with(job: SaveDocumentRevisionJob, args: [@document.id]) do
      patch document_path(@document), params: { document: { body: '<p>Once upon a time, again.</p>' } }
    end
    assert_response :success
  end

  test "saving fields that don't affect revisions queues no revision job" do
    assert_no_enqueued_jobs(only: SaveDocumentRevisionJob) do
      patch document_path(@document), params: { document: { privacy: 'public' } }
    end
  end

  test "mention job is only queued when the body has a mention token" do
    assert_no_enqueued_jobs(only: DocumentMentionJob) do
      patch document_path(@document), params: { document: { body: '<p>No mentions here.</p>' } }
    end

    assert_enqueued_with(job: DocumentMentionJob, args: [@document.id]) do
      patch document_path(@document), params: { document: { body: '<p>Meet [[Character-1]].</p>' } }
    end
  end

  test "mention job is not queued when the body is unchanged" do
    @document.update!(body: '<p>Meet [[Character-1]].</p>')

    assert_no_enqueued_jobs(only: DocumentMentionJob) do
      patch document_path(@document), params: { document: { title: 'New title', body: @document.body } }
    end
  end

  test "repeated saves within the debounce window queue one delayed job" do
    with_debounce(30.seconds) do
      assert_enqueued_jobs(1, only: SaveDocumentRevisionJob) do
        3.times do |i|
          patch document_path(@document), params: { document: { body: "<p>Edit #{i}</p>" } }
        end
      end
    end

    job = enqueued_jobs.find { |j| j[:job] == SaveDocumentRevisionJob }
    assert job[:at].present?, "expected the revision job to be scheduled for the end of the window"
    assert_equal '<p>Edit 2</p>', @document.reload.body
  end

  test "a Redis failure while queueing jobs does not fail the save" do
    failing_enqueue = ->(*) { raise RedisClient::ReadTimeoutError, 'timed out' }

    SaveDocumentRevisionJob.stub(:perform_later, failing_enqueue) do
      patch document_path(@document), params: { document: { body: '<p>Saved anyway.</p>' } }
    end

    assert_response :success
    assert_equal '<p>Saved anyway.</p>', @document.reload.body
  end

  private

  def with_debounce(wait)
    original_store = Rails.cache
    original_wait  = Rails.application.config.x.document_job_debounce
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    Rails.application.config.x.document_job_debounce = wait
    yield
  ensure
    Rails.cache = original_store
    Rails.application.config.x.document_job_debounce = original_wait
  end
end
