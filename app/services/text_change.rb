# What changed between two versions of a text, measured cheaply enough to run on every autosave.
module TextChange
  # Comparisons walk the texts in slices this long, so finding where two 1MB texts differ allocates
  # about as much as the texts themselves, however far apart the edits are.
  SLICE_BYTES = 65_536

  # Whether going from old_text to new_text removed at least `words` words of old_text: the words in
  # what lies between the text the two share at the start and at the end.
  def self.removed_at_least?(old_text, new_text, words)
    return false if old_text == new_text || words <= 0

    prefix = common_prefix_bytes(old_text, new_text)
    suffix = common_suffix_bytes(old_text, new_text, [old_text.bytesize, new_text.bytesize].min - prefix)
    removed = old_text.byteslice(prefix, old_text.bytesize - prefix - suffix)

    # Only whether there are `words` words matters, so a long removal is only counted part way
    WordCountService.count(removed.byteslice(0, SLICE_BYTES).scrub('')) >= words
  end

  def self.common_prefix_bytes(a, b)
    limit = [a.bytesize, b.bytesize].min
    start = 0
    start += SLICE_BYTES while start + SLICE_BYTES <= limit && a.byteslice(start, SLICE_BYTES) == b.byteslice(start, SLICE_BYTES)

    # Binary search within the first slice that differs
    low = start
    high = [start + SLICE_BYTES, limit].min
    while low < high
      mid = (low + high + 1) / 2
      a.byteslice(start, mid - start) == b.byteslice(start, mid - start) ? low = mid : high = mid - 1
    end
    low
  end

  # The bytes the two texts share at the end, at most `limit` (so it can't overlap the shared start)
  def self.common_suffix_bytes(a, b, limit)
    matched = 0
    matched += SLICE_BYTES while matched + SLICE_BYTES <= limit && tail(a, matched, SLICE_BYTES) == tail(b, matched, SLICE_BYTES)

    low = matched
    high = [matched + SLICE_BYTES, limit].min
    while low < high
      mid = (low + high + 1) / 2
      tail(a, matched, mid - matched) == tail(b, matched, mid - matched) ? low = mid : high = mid - 1
    end
    low
  end

  # `length` bytes ending `skip` bytes before the end of `text`
  def self.tail(text, skip, length)
    text.byteslice(text.bytesize - skip - length, length)
  end
  private_class_method :tail
end
