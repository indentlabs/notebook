module WritingGoalsHelper
  # National Novel Writing Month: 50,000 words of a novel during November.
  NANOWRIMO_WORD_COUNT = 50_000

  # November 1 of the National Novel Writing Month the dashboard should invite
  # the signed-in writer to set a goal for, or nil. The invitation runs from
  # October 15 to the end of November, and stops once the writer has a goal
  # starting in November or dismisses it for the year.
  def nanowrimo_prompt_start_date
    return unless user_signed_in?

    today = current_user.current_date_in_time_zone
    november = Date.new(today.year, 11, 1)
    return unless today.between?(Date.new(today.year, 10, 15), november.end_of_month)
    return unless show_notice?(id: nanowrimo_notice_id(november.year))
    return if current_user.writing_goals.not_archived.where(start_date: november..november.end_of_month).exists?

    november
  end

  # Each year has its own notice ID (202611 for November 2026), so dismissing
  # the invitation only hides it until next year.
  def nanowrimo_notice_id(year)
    "#{year}11".to_i
  end

  # The new-goal form filled in for all of November. Goal end dates are
  # exclusive (a 30-day goal started today ends 30 days from now), so this
  # runs from November 1 to December 1.
  def new_nanowrimo_goal_path(november)
    new_writing_goal_path(
      title:             "National Novel Writing Month #{november.year}",
      target_word_count: NANOWRIMO_WORD_COUNT,
      start_date:        november.iso8601,
      days:              november.end_of_month.day
    )
  end
end
