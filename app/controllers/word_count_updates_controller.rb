class WordCountUpdatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_word_count_update, only: [:update, :destroy]

  RECORDS_SHOWN = 200

  def index
    user_today = current_user.current_date_in_time_zone

    # Recent rows, each with what it added that day (its count minus the count its day started from)
    @updates = current_user.word_count_updates
                           .where.not(for_date: nil)
                           .with_previous_word_count
                           .order(for_date: :desc, updated_at: :desc)
                           .limit(RECORDS_SHOWN)
                           .to_a
    @entities = entities_for(@updates)
    # The oldest date shown may have more rows than fit in the list
    @partial_date = @updates.last.for_date if @updates.size == RECORDS_SHOWN

    # 30-Day Activity Chart
    dates = (0..29).map { |days_ago| user_today - days_ago.days }
    @word_counts_by_date = WordCountUpdate.batch_words_written_on_dates(current_user, dates)

    @dashboard_daily_activity = dates.map do |date|
      [date.strftime('%m/%d'), @word_counts_by_date[date] || 0]
    end.reverse

    # Simple form building object, dated today where the writer is
    @new_update = current_user.word_count_updates.build(for_date: user_today)
  end

  def create
    @new_update = current_user.word_count_updates.build(word_count_update_params)
    @new_update.entity_type = WordCountUpdate::MANUAL_ADJUSTMENT

    if save_with_unique_entity_id(@new_update)
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

  # Each adjustment needs its own entity_id so a writer can add several on one day. The unique
  # index on (entity_type, entity_id, for_date) covers every writer's adjustments, so pick a random
  # one and try another on the rare clash.
  def save_with_unique_entity_id(adjustment, attempts: 3)
    adjustment.entity_id = SecureRandom.random_number(2_000_000_000) + 1
    adjustment.save
  rescue ActiveRecord::RecordNotUnique
    attempts -= 1
    retry if attempts > 0
    adjustment.errors.add(:base, 'Please try again')
    false
  end

  # { [entity_type, entity_id] => entity } for the listed rows, one query per type
  def entities_for(updates)
    updates.reject(&:is_manual_adjustment?).group_by(&:entity_type).each_with_object({}) do |(entity_type, rows), entities|
      klass = entity_type.safe_constantize
      next unless klass && klass < ActiveRecord::Base

      scope = klass.where(id: rows.map(&:entity_id).uniq)
      scope = scope.includes(:timeline) if klass == TimelineEvent # its edit link is its timeline's
      scope.each { |entity| entities[[entity_type, entity.id]] = entity }
    end
  end

  def set_word_count_update
    @update = current_user.word_count_updates.find(params[:id])
  end

  def word_count_update_params
    params.require(:word_count_update).permit(:for_date, :word_count)
  end
end
