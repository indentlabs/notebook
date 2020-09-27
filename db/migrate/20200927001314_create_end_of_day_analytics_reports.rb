class CreateEndOfDayAnalyticsReports < ActiveRecord::Migration[6.0]
  def change
    create_table :end_of_day_analytics_reports do |t|
      t.date :day
      t.integer :user_signups
      t.integer :new_monthly_subscriptions
      t.integer :ended_monthly_subscriptions
      t.integer :new_trimonthly_subscriptions
      t.integer :ended_trimonthly_subscriptions
      t.integer :new_annual_subscriptions
      t.integer :ended_annual_subscriptions
      t.integer :paid_paypal_invoices
      t.integer :buildings_created
      t.integer :characters_created
      t.integer :conditions_created
      t.integer :continents_created
      t.integer :countries_created
      t.integer :creatures_created
      t.integer :deities_created
      t.integer :floras_created
      t.integer :foods_created
      t.integer :governments_created
      t.integer :groups_created
      t.integer :items_created
      t.integer :jobs_created
      t.integer :landmarks_created
      t.integer :languages_created
      t.integer :locations_created
      t.integer :lores_created
      t.integer :magics_created
      t.integer :planets_created
      t.integer :races_created
      t.integer :religions_created
      t.integer :scenes_created
      t.integer :schools_created
      t.integer :sports_created
      t.integer :technologies_created
      t.integer :towns_created
      t.integer :traditions_created
      t.integer :universes_created
      t.integer :vehicles_created
      t.integer :documents_created
      t.integer :documents_edited
      t.integer :timelines_created
      t.integer :stream_shares_created
      t.integer :stream_comments
      t.integer :collections_created
      t.integer :collection_submissions_created
      t.integer :thredded_threads_created
      t.integer :thredded_replies_created
      t.integer :thredded_private_messages_created
      t.integer :thredded_private_replies_created
      t.integer :document_analyses_created

      t.timestamps
    end
  end
end
