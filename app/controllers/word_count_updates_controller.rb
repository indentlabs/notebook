class WordCountUpdatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_word_count_update, only: [:update, :destroy]

  def index
    # Load user's recent word count updates
    @updates = current_user.word_count_updates
                           .order(for_date: :desc, created_at: :desc)
                           .limit(200)

    # We need to compute deltas for display
    # The simplest way is to replicate a bit of the batch_words_written logic 
    # but specifically per-record to show what they contributed.
    # Group by entity + calculate delta

    # 30-Day Activity Chart
    user_today = current_user.current_date_in_time_zone
    dates = (0..29).map { |days_ago| user_today - days_ago.days }
    @word_counts_by_date = WordCountUpdate.batch_words_written_on_dates(current_user, dates)

    @dashboard_daily_activity = dates.map do |date|
      [date.strftime('%m/%d'), @word_counts_by_date[date] || 0]
    end.reverse
    
    # Simple form building object
    @new_update = current_user.word_count_updates.build(for_date: Date.current)
  end

  def create
    @new_update = current_user.word_count_updates.build(word_count_update_params)
    @new_update.entity_type = 'ManualAdjustment'
    
    # Generate a unique integer ID to allow multiple adjustments per day without unique constraint violation
    @new_update.entity_id = (Time.now.to_f * 1000).to_i % 2_000_000_000

    if @new_update.save
      redirect_to word_count_updates_path, notice: 'Manual word count adjustment added.'
    else
      redirect_to word_count_updates_path, alert: "Failed to add adjustment: #{@new_update.errors.full_messages.to_sentence}"
    end
  end

  def update
    if @update.update(word_count_update_params)
      redirect_to word_count_updates_path, notice: 'Word count log updated.'
    else
      redirect_to word_count_updates_path, alert: "Failed to update record: #{@update.errors.full_messages.to_sentence}"
    end
  end

  def destroy
    @update.destroy
    redirect_to word_count_updates_path, notice: 'Word count log deleted.'
  end

  private

  def set_word_count_update
    @update = current_user.word_count_updates.find(params[:id])
  end

  def word_count_update_params
    params.require(:word_count_update).permit(:for_date, :word_count)
  end
end
