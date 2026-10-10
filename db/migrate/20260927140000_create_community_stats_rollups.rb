# Pre-aggregated, anonymous community stats for the public /community page.
# CommunityStatsRollup fills these from word_count_updates (and a few other
# tables) one day at a time, so the page never has to aggregate the raw data.
class CreateCommunityStatsRollups < ActiveRecord::Migration[6.1]
  def change
    # One row per (date, metric, key), e.g. (2026-09-27, 'words', 'Documents').
    create_table :community_daily_stats do |t|
      t.date    :date,   null: false
      t.string  :metric, null: false
      t.string  :key,    null: false, default: ''
      t.bigint  :value,  null: false, default: 0
      t.timestamps
    end
    add_index :community_daily_stats, [:date, :metric, :key], unique: true, name: 'index_community_daily_stats_unique'
    add_index :community_daily_stats, [:metric, :date]

    # Which users wrote at least one word in each month, so monthly (and
    # all-time) distinct writer counts don't need to rescan word counts.
    create_table :community_monthly_writers do |t|
      t.date    :month,   null: false
      t.integer :user_id, null: false
    end
    add_index :community_monthly_writers, [:month, :user_id], unique: true
    add_index :community_monthly_writers, :user_id
  end
end
