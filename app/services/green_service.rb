class GreenService < Service
  AVERAGE_WORDS_PER_PAGE           = 500
  AVERAGE_TIMELINE_EVENTS_PER_PAGE = 3
  SHEETS_OF_PAPER_PER_TREE         = 11_000 # source: https://ribble-pack.co.uk/blog/much-paper-comes-one-tree

  def self.physical_pages_equivalent_for(worldbuilding_page_type)
    # TODO: This would be better estimated with [average] word counts from pages (or a real total),
    # but we don't have that data computed (and definitely don't want to do so on each page load).
    # Until we have a better solution, these page counts come from printing out notebook pages
    # from http://www.notebook-paper.com/

    case worldbuilding_page_type
    when "Universe"   then 2
    when "Character"  then 6
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
    when "Lore"       then 8
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

  def self.trees_saved_by(worldbuilding_page_type)
    (physical_pages_equivalent_for(worldbuilding_page_type) * (worldbuilding_page_type.constantize.last.try(:id) || 0)) / SHEETS_OF_PAPER_PER_TREE.to_f
  end

  def self.total_document_pages_equivalent
    # Use a single query with conditional aggregation instead of 3 separate queries
    result = Document.with_deleted
      .where.not(cached_word_count: nil)
      .select(
        'COUNT(CASE WHEN cached_word_count <= 500 THEN 1 END) as small_docs_count',
        'SUM(CASE WHEN cached_word_count > 500 THEN cached_word_count ELSE 0 END) as large_docs_word_count',
        'COUNT(CASE WHEN cached_word_count > 500 THEN 1 END) as large_docs_count'
      ).take

    small_docs_count = result.small_docs_count || 0
    large_docs_word_count = result.large_docs_word_count || 0
    large_docs_count = result.large_docs_count || 0

    # Treat all <1-page documents as 1 page per document, since they'd print on separate pages
    total_pages = small_docs_count

    # For all >1-page documents, do a quick estimate of word count sum + num docs to also cover EOD page breaks
    total_pages += (large_docs_word_count / AVERAGE_WORDS_PER_PAGE.to_f).round
    total_pages += large_docs_count

    total_pages
  end

  def self.total_timeline_pages_equivalent(max_timeline_event_id = nil)
    max_id = max_timeline_event_id || (TimelineEvent.last.try(:id) || 0)
    (max_id / AVERAGE_TIMELINE_EVENTS_PER_PAGE.to_f).to_i
  end

  def self.total_physical_pages_equivalent(content_type, max_id: nil)
    case content_type.name
      when 'Timeline'
        GreenService.total_timeline_pages_equivalent(max_id)
      when 'Document'
        GreenService.total_document_pages_equivalent
      else
        fetched_max_id = max_id || (content_type.last.try(:id) || 0)
        GreenService.physical_pages_equivalent_for(content_type.name) * fetched_max_id
    end
  end

  # Batch-fetch max IDs for all content types in a single query
  # Returns a hash mapping content_type.name => max_id
  def self.max_ids_for_content_types(content_types)
    return {} if content_types.empty?

    queries = content_types.map do |content_type|
      case content_type.name
      when 'Timeline'
        # Timeline uses TimelineEvent's max ID from timeline_events table
        "SELECT 'TimelineEvent' as content_type, COALESCE(MAX(id), 0) as max_id FROM timeline_events"
      when 'Document'
        # Document table - include all records for total count
        "SELECT 'Document' as content_type, COALESCE(MAX(id), 0) as max_id FROM documents"
      else
        # Standard content types use pluralized lowercase table names
        table_name = content_type.name.downcase.pluralize
        "SELECT '#{content_type.name}' as content_type, COALESCE(MAX(id), 0) as max_id FROM #{table_name}"
      end
    end

    sql = queries.join(' UNION ALL ')
    results = ActiveRecord::Base.connection.execute(sql)

    # Convert to hash, handling both SQLite (hash) and MySQL (array) result formats
    results.to_a.each_with_object({}) do |row, hash|
      if row.is_a?(Hash)
        hash[row['content_type']] = row['max_id'].to_i
      else
        hash[row[0]] = row[1].to_i
      end
    end
  end

  def self.total_pages_saved_by(user)
    total_pages = 0

    user.content.each do |content_type, content_list|
      physical_page_equivalent_for_content_type = case content_type
        when 'Timeline'
          AVERAGE_TIMELINE_EVENTS_PER_PAGE * TimelineEvent.where(timeline_id: content_list.map(&:id)).count

        when 'Document'
          [
            content_list.inject(0) { |sum, doc| sum + (doc.cached_word_count || 0) } / GreenService::AVERAGE_WORDS_PER_PAGE.to_f, 
            content_list_count
          ].max

        else
          physical_pages_equivalent_for(content_type) * content_list.count
      end

      total_pages += physical_page_equivalent_for_content_type
    end
    
    total_pages
  end

  def self.total_trees_saved_by(user)
    total_pages_saved_by(user).to_f / GreenService::SHEETS_OF_PAPER_PER_TREE
  end
end