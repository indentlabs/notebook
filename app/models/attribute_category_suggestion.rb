class AttributeCategorySuggestion < ApplicationRecord
  # Number of times an attribute category must be used before it gets considered
  # as a suggested category. 
  USAGE_FREQUENCY_MINIMUM = 1

  # Number of suggestions to return over the API. Limiting this means the
  # most-used categories get suggested, while niche or less-used categories don't.
  SUGGESTIONS_RESULT_COUNT = 100
end
