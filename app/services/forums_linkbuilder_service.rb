class ForumsLinkbuilderService < Service
  def self.worldbuilding_url(page_type)
    self.content_to_url_map.fetch(page_type.name.to_sym, nil)
  end

  def self.content_to_url_map
    {
      'Character': '/forum/characters-board',
      'Condition': '/forum/conditions',
      'Creature': '/forum/characters', # [sic]
      'Flora': '/forum/flora',
      'Government': '/forum/governments',
      'Item': '/forum/items',
      'Job': '/forum/jobs',
      'Landmark': '/forum/landmarks',
      'Language': '/forum/languages', # wtf did I do
      'Location': '/forum/locations',
      'Magic': '/forum/magic',
      'Planet': '/forum/planets',
      'Race': '/forum/races',
      'Religion': '/forum/religions',
      'Technology': '/forum/technology',
      'Tradition': '/forum/traditions',
      'School': '/forum/schools',
      'Sport': '/forum/sports',
      'Food': '/forum/food'
    }
  end

  def self.is_discussions_page?(url)
    return url.start_with?('/forum/')
  end
end
