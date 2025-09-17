# frozen_string_literal: true

class ChangelogStatsService
  def initialize(content)
    @content = content
    @change_events = content.attribute_change_events
  end

  def total_changes
    @change_events.sum { |event| event.changed_fields.keys.length }
  end

  def active_days
    @change_events.map { |event| event.created_at.to_date }.uniq.length
  end

  def most_recent_activity
    @change_events.first&.created_at
  end

  def creation_date
    @content.created_at
  end

  def days_since_creation
    (Date.current - creation_date.to_date).to_i
  end

  def most_active_field
    field_counts = Hash.new(0)
    
    @change_events.each do |event|
      event.changed_fields.keys.each do |field_key|
        field_counts[field_key] += 1
      end
    end
    
    return nil if field_counts.empty?
    
    most_frequent_field_id = field_counts.max_by { |_, count| count }.first
    find_field_by_id(most_frequent_field_id)
  end

  def change_intensity_by_week
    # Group changes by week for the past 12 weeks
    weeks = []
    (0..11).each do |i|
      week_start = i.weeks.ago.beginning_of_week
      week_end = week_start.end_of_week
      
      changes_this_week = @change_events.select do |event|
        event.created_at >= week_start && event.created_at <= week_end
      end
      
      weeks << {
        week_start: week_start,
        week_end: week_end,
        change_count: changes_this_week.sum { |event| event.changed_fields.keys.length },
        event_count: changes_this_week.length
      }
    end
    
    weeks.reverse
  end

  def changes_by_day_of_week
    day_counts = Hash.new(0)
    
    @change_events.each do |event|
      day_name = event.created_at.strftime('%A')
      day_counts[day_name] += event.changed_fields.keys.length
    end
    
    # Return in week order
    %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday].map do |day|
      { day: day, count: day_counts[day] }
    end
  end

  def biggest_single_update
    biggest_event = @change_events.max_by { |event| event.changed_fields.keys.length }
    return nil unless biggest_event
    
    {
      event: biggest_event,
      field_count: biggest_event.changed_fields.keys.length,
      date: biggest_event.created_at
    }
  end

  def writing_streaks
    # Find consecutive days with changes
    change_dates = @change_events.map { |event| event.created_at.to_date }.uniq.sort.reverse
    
    return [] if change_dates.empty?
    
    streaks = []
    current_streak = [change_dates.first]
    
    change_dates.each_cons(2) do |current_date, next_date|
      if (current_date - next_date).to_i == 1
        current_streak << next_date
      else
        streaks << current_streak if current_streak.length > 1
        current_streak = [next_date]
      end
    end
    
    streaks << current_streak if current_streak.length > 1
    streaks.sort_by(&:length).reverse
  end

  def longest_writing_streak
    streaks = writing_streaks
    return nil if streaks.empty?
    
    longest = streaks.first
    {
      length: longest.length,
      start_date: longest.last,
      end_date: longest.first
    }
  end

  def grouped_changes_by_date
    # Group changes by date for timeline display
    grouped = @change_events.group_by { |event| event.created_at.to_date }
    
    grouped.map do |date, events|
      {
        date: date,
        events: events,
        total_field_changes: events.sum { |event| event.changed_fields.keys.length },
        users: events.map(&:user).compact.uniq
      }
    end.sort_by { |group| group[:date] }.reverse
  end

  private

  def find_field_by_id(field_id)
    # Get related attribute and field information
    related_attribute = Attribute.find_by(id: @change_events.map(&:content_id).uniq)
    return nil unless related_attribute
    
    AttributeField.find_by(id: related_attribute.attribute_field_id)
  end
end