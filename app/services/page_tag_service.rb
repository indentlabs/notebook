class PageTagService < Service
  def self.slug_for(text)
    text.downcase.gsub(/[^0-9a-z ]/i, '').gsub(/ /, '-')
  end
end
