require 'test_helper'

class CacheLockTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  # Production's FileStore and the MemoryStore both refuse an unless_exist write while an expired
  # entry is still stored, so a lock that is never read would never be released.
  [ActiveSupport::Cache::MemoryStore, ActiveSupport::Cache::FileStore].each do |store_class|
    test "a lock can be taken again once it has expired (#{store_class.name.demodulize})" do
      Dir.mktmpdir do |dir|
        with_cache(store_class == ActiveSupport::Cache::FileStore ? store_class.new(dir) : store_class.new) do
          assert CacheLock.acquire('lock/test', expires_in: 30.seconds)
          refute CacheLock.acquire('lock/test', expires_in: 30.seconds)

          travel 31.seconds do
            assert CacheLock.acquire('lock/test', expires_in: 30.seconds)
            refute CacheLock.acquire('lock/test', expires_in: 30.seconds)
          end
        end
      end
    end
  end

  test "release frees the lock straight away" do
    with_cache(ActiveSupport::Cache::MemoryStore.new) do
      assert CacheLock.acquire('lock/test', expires_in: 1.hour)
      CacheLock.release('lock/test')
      assert CacheLock.acquire('lock/test', expires_in: 1.hour)
    end
  end

  test "the community stats refresh is queued again after its lock window" do
    with_cache(ActiveSupport::Cache::MemoryStore.new) do
      assert_enqueued_jobs(1, only: CommunityStatsRefreshJob) do
        CommunityStatsRefreshJob.enqueue_unless_pending
        CommunityStatsRefreshJob.enqueue_unless_pending
      end

      travel 16.minutes do
        assert_enqueued_jobs(1, only: CommunityStatsRefreshJob) do
          CommunityStatsRefreshJob.enqueue_unless_pending
        end
      end
    end
  end

  private

  def with_cache(store)
    original = Rails.cache
    Rails.cache = store
    yield
  ensure
    Rails.cache = original
  end
end
