class ForumsLinkbuilderService < Service
  def self.worldbuilding_url(page_type)
    self.content_to_url_map.fetch(page_type, nil)
  end

  def self.content_to_url_map
    {
      'Character': '/forum/characters-board',
      'Creature': '/forum/characters', # [sic]
      'Flora': '/forum/flora',
      'Government': '/forum/governments',
      'Language': '/forum/general-worldbuilding', # wtf did I do
      'Location': '/forum/locations',
      'Magic': '/forum/magic',
      'Planet': '/forum/planets',
      'Religion': '/forum/religions',
      'Technology': '/forum/technology'
    }
  end
end
