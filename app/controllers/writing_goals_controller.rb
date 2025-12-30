class WritingGoalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_writing_goal, only: [:edit, :update, :destroy, :complete, :activate, :archive]
  before_action :set_sidenav_expansion

  def index
    @page_title = "Writing Goals"
    @active_goals = current_user.writing_goals.current.order(end_date: :asc)
    @archived_goals_count = current_user.writing_goals.where('archived = ? OR completed_at IS NOT NULL', true).count

    # Daily stats for header (always show, even without active goals)
    # Uses User#daily_word_goal which defaults to 1,000 if no active goals
    @max_daily_goal = current_user.daily_word_goal

    # Words written today
    @words_today = current_user.words_written_today

    # Progress toward daily goal
    @daily_progress_percentage = @max_daily_goal > 0 ? [(@words_today.to_f / @max_daily_goal * 100), 100.0].min : 0

    # Words remaining today
    @words_remaining_today = [@max_daily_goal - @words_today, 0].max

    # 30-day word count history for chart (use user's timezone)
    user_today = current_user.current_date_in_time_zone
    dates = ((user_today - 29.days)..user_today).to_a
    @daily_word_counts_30_days = WordCountUpdate.words_written_on_dates(current_user, dates)
  end

  def history
    @page_title = "Writing Goals History"

    # Auto-complete any expired goals that weren't manually completed/archived
    user_today = current_user.current_date_in_time_zone
    current_user.writing_goals
      .where(archived: false, completed_at: nil)
      .where('end_date < ?', user_today)
      .find_each { |goal| goal.update(completed_at: Time.current, active: false) }

    @archived_goals = current_user.writing_goals
      .where('archived = ? OR completed_at IS NOT NULL', true)
      .order(end_date: :desc)
  end

  def new
    @page_title = "New Writing Goal"
    @writing_goal = current_user.writing_goals.build

    # Suggest novel challenge defaults (use user's timezone for dates)
    user_today = current_user.current_date_in_time_zone
    @writing_goal.title = "My Writing Goal"
    @writing_goal.target_word_count = 50000
    @writing_goal.start_date = user_today
    @writing_goal.end_date = user_today + 30.days
  end

  def create
    @writing_goal = current_user.writing_goals.build(writing_goal_params)

    if @writing_goal.save
      redirect_to writing_goals_path, notice: 'Writing goal created successfully!'
    else
      @page_title = "New Writing Goal"
      render :new
    end
  end

  def edit
    @page_title = "Edit Writing Goal"
  end

  def update
    if @writing_goal.update(writing_goal_params)
      redirect_to writing_goals_path, notice: 'Writing goal updated successfully!'
    else
      @page_title = "Edit Writing Goal"
      render :edit
    end
  end

  def destroy
    @writing_goal.destroy
    redirect_to writing_goals_path, notice: 'Writing goal deleted.'
  end

  def complete
    @writing_goal.update(active: false, completed_at: Time.current)
    redirect_to writing_goals_path, notice: 'Goal marked as complete!'
  end

  def activate
    @writing_goal.update(active: true, archived: false, completed_at: nil)
    redirect_to writing_goals_path, notice: 'Goal activated!'
  end

  def archive
    @writing_goal.archive!
    redirect_to writing_goals_path, notice: 'Goal archived.'
  end

  private

  def set_writing_goal
    @writing_goal = current_user.writing_goals.find(params[:id])
  end

  def writing_goal_params
    params.require(:writing_goal).permit(:title, :target_word_count, :start_date, :end_date)
  end

  def set_sidenav_expansion
    @sidenav_expansion = 'writing'
  end
end
