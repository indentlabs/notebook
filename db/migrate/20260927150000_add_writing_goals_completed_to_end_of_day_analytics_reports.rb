class AddWritingGoalsCompletedToEndOfDayAnalyticsReports < ActiveRecord::Migration[6.1]
  def change
    add_column :end_of_day_analytics_reports, :writing_goals_completed, :integer
  end
end
