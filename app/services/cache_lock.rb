# A short-lived "only one of these at a time" lock kept in Rails.cache.
#
# Rails.cache.write(key, value, unless_exist: true) is not enough on its own: on the FileStore
# (production) and MemoryStore in Rails 6.1, it refuses the write while an *expired* entry is still
# stored, and an expired entry is only removed when that key is read. Nothing else reads these
# keys, so a lock taken once would never be released and the work it guards would never run again.
# Reading first purges an expired entry, so the write can take the lock again once it has expired.
module CacheLock
  # Returns true if this caller took the lock, false if someone else holds it.
  def self.acquire(key, expires_in:)
    Rails.cache.read(key)
    Rails.cache.write(key, true, unless_exist: true, expires_in: expires_in)
  end

  def self.release(key)
    Rails.cache.delete(key)
  end
end
