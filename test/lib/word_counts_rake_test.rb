require 'test_helper'
require 'rake'

class WordCountsRakeTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?('word_counts:recount_cached')
    %w[word_counts:recount_cached word_counts:recover_untracked_writing].each { |task| Rake::Task[task].reenable }
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

  test "recover_untracked_writing records a document's stuck-period writing on the day it was last saved" do
    document = Document.create!(user: @user, title: 'Novel', body: '<p>Day one words.</p>')
    last_job_at = Time.utc(2026, 11, 1, 12, 0)
    document.document_revisions.create!(title: 'Novel', body: document.body, cached_word_count: 3,
                                        created_at: last_job_at, updated_at: last_job_at)
    document.word_count_updates.create!(user: @user, for_date: Date.new(2026, 11, 1), word_count: 3)
    # Written while the lock was stuck, and not saved since: no rows
    document.update_columns(body: '<p>Day one words.</p><p>Written on later days.</p>', updated_at: Time.utc(2026, 11, 4, 20, 0))

    assert_output(/were last saved on a day with no word count row/) do
      Rake::Task['word_counts:recover_untracked_writing'].invoke
    end
    assert_nil document.word_count_updates.find_by(for_date: Date.new(2026, 11, 4))

    Rake::Task['word_counts:recover_untracked_writing'].reenable
    ENV['DRY_RUN'] = 'false'
    assert_output(/Recorded untracked writing/) { Rake::Task['word_counts:recover_untracked_writing'].invoke }

    assert_equal 4, WordCountUpdate.words_written_on_date(@user, Date.new(2026, 11, 4))
  ensure
    ENV.delete('DRY_RUN')
  end

  test "recount_cached moves today's start with a page's recount, so it isn't credited" do
    category = AttributeCategory.create!(user: @user, name: 'overview', label: 'Overview', entity_type: 'character')
    field = AttributeField.create!(user: @user, attribute_category: category, label: 'Role', name: 'role', field_type: 'text_area')
    character = Character.create!(user: @user, name: 'Aria')
    attribute = Attribute.create!(user: @user, attribute_field: field, entity: character, value: 'She paused--then ran away')
    # Counted the old way, and edited today
    attribute.update_column(:word_count_cache, 4)
    character.update_column(:cached_word_count, 4)
    character.word_count_updates.create!(user: @user, for_date: Date.current, starting_word_count: 2, word_count: 4)

    assert_output(/Character: done/) { Rake::Task['word_counts:recount_cached'].invoke }

    assert_equal 5, character.reload.cached_word_count
    assert_equal 2, WordCountUpdate.words_written_on_date(@user, Date.current)
  end
end
