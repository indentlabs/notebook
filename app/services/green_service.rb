class GreenService < Service
  AVERAGE_WORDS_PER_PAGE           = 500
  AVERAGE_TIMELINE_EVENTS_PER_PAGE = 3

  def physical_pages_equivalent_for(worldbuilding_page_type)
    # TODO: This would be better estimated with [average] word counts from pages (or a real total),
    # but we don't have that data computed (and definitely don't want to do so on each page load).
    # Until we have a better solution, these page counts come from printing out notebook pages
    # from http://www.notebook-paper.com/ 

    case worldbuilding_page_type
    when "Universe"   then 2  * Universe.last.id
    when "Character"  then 8  * Character.last.id
    when "Location"   then 4  * Location.last.id
    when "Item"       then 2  * Item.last.id
    when "Building"   then 8  * Building.last.id
    when "Condition"  then 4  * Condition.last.id
    when "Continent"  then 6  * Continent.last.id
    when "Country"    then 5  * Country.last.id
    when "Creature"   then 8  * Creature.last.id
    when "Deity"      then 5  * Deity.last.id
    when "Flora"      then 4  * Flora.last.id
    when "Food"       then 5  * Food.last.id
    when "Government" then 6  * Government.last.id
    when "Group"      then 4  * Group.last.id
    when "Job"        then 4  * Job.last.id
    when "Landmark"   then 3  * Landmark.last.id
    when "Language"   then 5  * Language.last.id
    when "Lore"       then 10 * Lore.last.id
    when "Magic"      then 4  * Magic.last.id
    when "Planet"     then 6  * Planet.last.id
    when "Race"       then 4  * Race.last.id
    when "Religion"   then 3  * Religion.last.id
    when "Scene"      then 2  * Scene.last.id
    when "School"     then 6  * School.last.id
    when "Sport"      then 4  * Sport.last.id
    when "Technology" then 4  * Technology.last.id
    when "Town"       then 4  * Town.last.id
    when "Tradition"  then 3  * Tradition.last.id
    when "Vehicle"    then 4  * Vehicle.last.id
    else
      raise "Unknown green estimate: #{worldbuilding_page_type}"
    end
  end

  def total_document_pages_equivalent
    (Document.with_deleted.sum(:cached_word_count) / AVERAGE_WORDS_PER_PAGE.to_f).to_i
  end

  def total_timeline_pages_equivalent
    (TimelineEvent.last.id / AVERAGE_TIMELINE_EVENTS_PER_PAGE.to_f).to_i
  end
end