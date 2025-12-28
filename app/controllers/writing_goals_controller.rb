class WritingGoalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_writing_goal, only: [:edit, :update, :destroy, :complete, :activate, :archive]
  before_action :set_sidenav_expansion

  def index
    @page_title = "Writing Goals"
    @active_goals = current_user.writing_goals.current.order(end_date: :asc)
    @archived_goals_count = current_user.writing_goals.where('archived = ? OR completed_at IS NOT NULL', true).count
  end

  def history
    @page_title = "Writing Goals History"
    @archived_goals = current_user.writing_goals.where('archived = ? OR completed_at IS NOT NULL', true).order(end_date: :desc)
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
