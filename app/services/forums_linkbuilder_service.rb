class ForumsLinkbuilderService < Service
  def self.worldbuilding_url(page_type)
    case page_type.name
    when 'Character'
      '/forum/characters-board'
    when 'Creature'
      '/forum/characters' # [sic]
    when 'Flora'
      '/forum/flora'
    when 'Government'
      '/forum/governments'
    when 'Language'
      '/forum/general-worldbuilding' # wtf did I do here
    when 'Location'
      '/forum/locations'
    when 'Magic'
      '/forum/magic'
    when 'Planet'
      '/forum/planets'
    when 'Religion'
      '/forum/religions'
    when 'Technology'
      '/forum/technology'
    end
  end
end
