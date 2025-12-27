class WritingGoalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_writing_goal, only: [:edit, :update, :destroy, :complete, :activate]
  before_action :set_sidenav_expansion

  def index
    @page_title = "Writing Goals"
    @active_goal = current_user.writing_goals.current.first
    @past_goals = current_user.writing_goals.where(active: false).order(end_date: :desc)

    if @active_goal
      calculate_goal_statistics(@active_goal)
    end

    @daily_word_counts = fetch_daily_word_counts
  end

  def new
    @page_title = "New Writing Goal"
    @writing_goal = current_user.writing_goals.build

    # Suggest NaNoWriMo-style defaults
    @writing_goal.title = "My Writing Goal"
    @writing_goal.target_word_count = 50000
    @writing_goal.start_date = Date.current
    @writing_goal.end_date = Date.current + 30.days
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
    # Deactivate any other active goals
    current_user.writing_goals.active.update_all(active: false)
    @writing_goal.update(active: true, completed_at: nil)
    redirect_to writing_goals_path, notice: 'Goal activated!'
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

  def calculate_goal_statistics(goal)
    @words_written_today = current_user.words_written_today
    @words_written_this_week = WordCountUpdate
      .where(user: current_user)
      .where(for_date: Date.current.beginning_of_week..Date.current)
      .sum(:word_count)

    @words_written_during_goal = goal.words_written_during_goal
    @daily_goal = goal.daily_goal
    @original_daily_goal = goal.original_daily_goal
    @progress_percentage = goal.progress_percentage
    @ahead_or_behind = goal.ahead_or_behind
    @days_remaining = goal.days_remaining
  end

  def fetch_daily_word_counts
    return {} unless @active_goal

    WordCountUpdate.where(user: current_user)
                   .where(for_date: @active_goal.start_date..Date.current)
                   .group(:for_date)
                   .sum(:word_count)
  end
end
