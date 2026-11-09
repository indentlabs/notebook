require 'test_helper'
require 'rake'

class WordCountsRakeTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?('word_counts:recount_cached')
    %w[word_counts:recount_cached word_counts:recover_stuck_lock_writing].each { |task| Rake::Task[task].reenable }
    @user = User.create!(email: 'word_counts_rake@example.com', password: 'password123', time_zone: 'UTC')
  end

  test "recount_cached fixes stored counts without crediting anything" do
    document = Document.create!(user: @user, title: 'Novel', body: '<p>One two.</p><p>Three four.</p>')
    document.update_column(:cached_word_count, 3) # the old editor's count
    revision = document.document_revisions.create!(title: 'Novel', body: document.body, cached_word_count: 3)

    assert_no_difference 'WordCountUpdate.count' do
      assert_output(/Documents: done/) { Rake::Task['word_counts:recount_cached'].invoke }
    end

    assert_equal 4, document.reload.cached_word_count
    assert_equal 4, revision.reload.cached_word_count
  end

  test "recover_stuck_lock_writing credits the stuck period to the last day saved and adds a revision" do
    document = Document.create!(user: @user, title: 'Novel', body: '<p>Day one words.</p>')
    last_job_at = Time.utc(2026, 11, 1, 12, 0)
    document.document_revisions.create!(title: 'Novel', body: document.body, cached_word_count: 3,
                                        created_at: last_job_at, updated_at: last_job_at)
    document.word_count_updates.create!(user: @user, for_date: Date.new(2026, 11, 1), word_count: 3)
    # Written while the lock was stuck: no rows, no revisions
    document.update_columns(body: '<p>Day one words.</p><p>Written on later days.</p>', updated_at: Time.utc(2026, 11, 4, 20, 0))

    assert_output(/word count rows would be recorded/) do
      Rake::Task['word_counts:recover_stuck_lock_writing'].invoke
    end
    assert_nil document.word_count_updates.find_by(for_date: Date.new(2026, 11, 4))

    Rake::Task['word_counts:recover_stuck_lock_writing'].reenable
    ENV['DRY_RUN'] = 'false'
    assert_output(/word count rows recorded/) { Rake::Task['word_counts:recover_stuck_lock_writing'].invoke }

    assert_equal 4, WordCountUpdate.words_written_on_date(@user, Date.new(2026, 11, 4))
    newest = document.document_revisions.order(:created_at).last
    assert_equal document.body, newest.body
    assert_equal Time.utc(2026, 11, 4, 20, 0), newest.created_at
    assert newest.closed_at
  ensure
    ENV.delete('DRY_RUN')
  end
end
