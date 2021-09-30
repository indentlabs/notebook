class AddDocumentRevisionsCreatedToEndOfDayAnalyticsReports < ActiveRecord::Migration[6.0]
  def change
    add_column :end_of_day_analytics_reports, :document_revisions_created, :integer
  end
end
