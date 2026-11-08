require 'test_helper'

# Word counts for notebook pages, timeline events and books
class PageWordCountJobsTest < ActiveJob::TestCase
  setup do
    @user = User.create!(email: 'page_counts_test@example.com', password: 'password123', time_zone: 'UTC')
    @category = AttributeCategory.create!(user: @user, name: 'overview', label: 'Overview', entity_type: 'character')
    @role = AttributeField.create!(user: @user, attribute_category: @category, label: 'Role', name: 'role', field_type: 'text_area')
    @backstory = AttributeField.create!(user: @user, attribute_category: @category, label: 'Backstory', name: 'backstory', field_type: 'text_area')
    @universe_field = AttributeField.create!(user: @user, attribute_category: @category, label: 'Universe', name: 'universe', field_type: 'universe')
    @character = Character.create!(user: @user, name: 'Aria')

    # Recount locks live in Rails.cache; keep them from leaking between tests
    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rails.cache = @original_cache
  end

  def row_for(entity, date = Date.current)
    entity.word_count_updates.find_by(for_date: date)
  end

  # Saves a field value the way the page editor does, then runs the jobs that queued
  def save_field(field, value)
    attribute = Attribute.find_or_initialize_by(attribute_field: field, entity: @character)
    attribute.user ||= @user
    attribute.value = value
    attribute.save!
    perform_enqueued_jobs
    attribute
  end

  test "a field edit queues one job that recounts the field, then the page" do
    assert_enqueued_jobs(1, only: CacheAttributeWordCountJob) do
      assert_no_enqueued_jobs(only: CacheSumAttributeWordCountJob) do
        Attribute.create!(user: @user, attribute_field: @role, entity: @character, value: 'The hero')
      end
    end

    perform_enqueued_jobs
    assert_equal 2, @character.reload.cached_word_count
    assert_equal 2, row_for(@character).word_count
  end

  test "a new page's words all count as written" do
    save_field(@role, 'The reluctant hero')
    save_field(@backstory, 'Raised by wolves in the north')

    assert_equal 0, row_for(@character).starting_word_count
    assert_equal 9, WordCountUpdate.words_written_on_date(@user, Date.current)
  end

  test "the first edit of an old page credits only what it changed" do
    travel_to 1.year.ago do
      save_field(@role, 'The reluctant hero')
      save_field(@backstory, 'Raised by wolves in the north, long ago, before the war')
    end
    # Pages from before word counts were tracked have no rows and no cached total
    WordCountUpdate.where(entity: @character).delete_all
    @character.update_column(:cached_word_count, 0)

    save_field(@role, 'The reluctant hero of the story')

    assert_equal 3, WordCountUpdate.words_written_on_date(@user, Date.current)
  end

  test "a field whose count was never cached is measured from its old text" do
    travel_to 1.year.ago do
      save_field(@backstory, 'Raised by wolves in the north')
    end
    Attribute.find_by(attribute_field: @backstory, entity: @character).update_column(:word_count_cache, nil)
    WordCountUpdate.where(entity: @character).delete_all
    @character.update_column(:cached_word_count, 0)

    save_field(@backstory, 'Raised by wolves in the north, then by bears')

    assert_equal 3, WordCountUpdate.words_written_on_date(@user, Date.current)
  end

  test "changing a non-prose field doesn't credit the page's words" do
    travel_to 1.month.ago do
      save_field(@role, 'The reluctant hero')
    end
    WordCountUpdate.where(entity: @character).delete_all
    @character.update_column(:cached_word_count, 0)

    save_field(@universe_field, '12')

    assert_equal 0, WordCountUpdate.words_written_on_date(@user, Date.current)
  end

  test "deleting a field recounts its page without counting as writing" do
    travel_to 2.days.ago do
      save_field(@role, 'The reluctant hero')
      save_field(@backstory, 'Raised by wolves in the north')
    end

    Attribute.find_by(attribute_field: @backstory, entity: @character).destroy
    assert_enqueued_jobs 1, only: CacheSumAttributeWordCountJob
    perform_enqueued_jobs

    assert_equal 3, @character.reload.cached_word_count
    assert_equal 0, WordCountUpdate.words_written_on_date(@user, Date.current)

    # The next day's writing isn't cancelled out by the deleted words
    travel 1.day do
      save_field(@role, 'The reluctant hero of the north')
      assert_equal 3, WordCountUpdate.words_written_on_date(@user, Date.current)
    end
  end

  test "a page that fails validation still gets its count saved" do
    @character.update_column(:name, '')
    save_field(@role, 'Nameless wanderer')

    assert_equal 2, @character.reload.cached_word_count
  end

  test "a timeline event's day starts from its text before the edit" do
    timeline = Timeline.create!(user: @user, name: 'History')
    event = timeline.timeline_events.create!(title: 'The war', description: 'It was long.')
    perform_enqueued_jobs
    assert_equal 5, WordCountUpdate.words_written_on_date(@user, Date.current)

    travel 1.day do
      event.update!(description: 'It was long, and nobody won.')
      perform_enqueued_jobs
      assert_equal 3, row_for(event, Date.current).word_count - row_for(event, Date.current).starting_word_count
    end
  end

  test "a book's first tracked edit doesn't credit its existing blurb" do
    book = Book.create!(user: @user, name: 'Saga')
    book.update_columns(blurb: 'A long blurb written before word counts were tracked for books.')

    book.update!(blurb: book.blurb + ' Now longer.')
    perform_enqueued_jobs

    assert_equal 2, WordCountUpdate.words_written_on_date(@user, Date.current)
  end
end
