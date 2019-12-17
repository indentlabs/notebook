class AttributeFieldSuggestion < ApplicationRecord
  # Number of times an attribute field must be used before it gets considered
  # as a suggested field. 
  USAGE_FREQUENCY_MINIMUM = 10

  # Number of suggestions to return over the API. Limiting this means the
  # most-used fields get suggested, while niche or less-used fields don't.
  SUGGESTIONS_RESULT_COUNT = 100
end
