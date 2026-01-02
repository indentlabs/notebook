class WritingGoal < ApplicationRecord
  belongs_to :user

  # Returns the current date in the user's configured timezone
  def user_current_date
    user&.time_zone.present? ? Time.current.in_time_zone(user.time_zone).to_date : Date.current
  end

  validates :title, presence: true
  validates :target_word_count, presence: true, numericality: { greater_than: 0 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  scope :active, -> { where(active: true) }
  scope :completed, -> { where.not(completed_at: nil) }
  scope :archived, -> { where(archived: true) }
  scope :not_archived, -> { where(archived: false) }
  scope :current, -> { active.not_archived.where('end_date >= ?', Date.current) }

  def days_remaining
    return 0 if user_current_date > end_date
    (end_date - user_current_date).to_i
  end

  def total_days
    (end_date - start_date).to_i
  end

  def days_elapsed
    return 0 if user_current_date < start_date
    [total_days, (user_current_date - start_date).to_i].min
  end

  def words_written_during_goal
    WordCountUpdate.words_written_in_range(user, start_date..user_current_date)
  end

  def words_remaining
    [target_word_count - words_written_during_goal, 0].max
  end

  def daily_goal
    return 0 if days_remaining.zero?
    (words_remaining.to_f / days_remaining).ceil
  end

  def original_daily_goal
    return 0 if total_days.zero?
    (target_word_count.to_f / total_days).ceil
  end

  def progress_percentage
    return 100.0 if target_word_count.zero?
    [(words_written_during_goal.to_f / target_word_count * 100), 100.0].min
  end

  def expected_words_by_today
    return target_word_count if user_current_date >= end_date
    return 0 if user_current_date < start_date
    (original_daily_goal * days_elapsed)
  end

  def ahead_or_behind
    words_written_during_goal - expected_words_by_today
  end

  def on_track?
    ahead_or_behind >= 0
  end

  def completed?
    completed_at.present? || words_written_during_goal >= target_word_count
  end

  def mark_completed!
    update(completed_at: Time.current, active: false) if completed?
  end

  def archive!
    update(archived: true)
  end

  def unarchive!
    update(archived: false)
  end

  def daily_word_counts
    end_dt = [user_current_date, end_date].min
    dates = (start_date..end_dt).to_a
    WordCountUpdate.words_written_on_dates(user, dates)
  end

  private

  def end_date_after_start_date
    return unless start_date && end_date
    if end_date <= start_date
      errors.add(:end_date, 'must be after start date')
    end
  end
end
