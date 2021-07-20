class GreenService < Service
  AVERAGE_WORDS_PER_PAGE           = 500
  AVERAGE_TIMELINE_EVENTS_PER_PAGE = 3
  SHEETS_OF_PAPER_PER_TREE         = 15_000

  def self.physical_pages_equivalent_for(worldbuilding_page_type)
    # TODO: This would be better estimated with [average] word counts from pages (or a real total),
    # but we don't have that data computed (and definitely don't want to do so on each page load).
    # Until we have a better solution, these page counts come from printing out notebook pages
    # from http://www.notebook-paper.com/

    case worldbuilding_page_type
    when "Universe"   then 2
    when "Character"  then 8
    when "Location"   then 4
    when "Item"       then 2
    when "Building"   then 8
    when "Condition"  then 4
    when "Continent"  then 6
    when "Country"    then 5
    when "Creature"   then 8
    when "Deity"      then 5
    when "Flora"      then 4
    when "Food"       then 5
    when "Government" then 6
    when "Group"      then 4
    when "Job"        then 4
    when "Landmark"   then 3
    when "Language"   then 5
    when "Lore"       then 10
    when "Magic"      then 4
    when "Planet"     then 6
    when "Race"       then 4
    when "Religion"   then 3
    when "Scene"      then 2
    when "School"     then 6
    when "Sport"      then 4
    when "Technology" then 4
    when "Town"       then 4
    when "Tradition"  then 3
    when "Vehicle"    then 4
    else
      raise "Unknown green estimate: #{worldbuilding_page_type}"
    end
  end

  def self.total_document_pages_equivalent
    (Document.with_deleted.sum(:cached_word_count) / AVERAGE_WORDS_PER_PAGE.to_f).round
  end

  def self.total_timeline_pages_equivalent
    (TimelineEvent.last.id / AVERAGE_TIMELINE_EVENTS_PER_PAGE.to_f).to_i
  end
end