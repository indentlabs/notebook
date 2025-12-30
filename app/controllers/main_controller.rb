# Controller for top-level pages of the site that do not have
# an associated model
class MainController < ApplicationController
  #layout 'landing', only: [:about_notebook, :for_writers, :for_roleplayers, :for_friends]

  before_action :authenticate_user!, only: [:dashboard, :prompts, :notes, :recent_content]
  before_action :cache_linkable_content_for_each_content_type, only: [:dashboard, :prompts]
  before_action :set_page_meta_tags

  before_action do
    if !user_signed_in? && params[:referral]
      session[:referral] = params[:referral]
    end
  end

  def index
    redirect_to(:dashboard) if user_signed_in?

    @resource ||= User.new
    @resource_name = :user
    @devise_mapping ||= Devise.mappings[:user]
  end

  def about_notebook
  end

  def comingsoon
  end

  def dashboard
    @page_title = "My notebook"

    # Trending = topics with most posts in the last 30 days
    messageboard_ids_to_exclude = [38, 26, 31, 32, 30, 33, 27]
    @most_recent_threads = Thredded::Topic
      .joins(:posts)
      .where.not(messageboard_id: messageboard_ids_to_exclude)
      .where(moderation_state: "approved")
      .where('thredded_posts.created_at > ?', 30.days.ago)
      .group('thredded_topics.id')
      .order('COUNT(thredded_posts.id) DESC')
      .includes(:messageboard)
      .limit(6)
    
    # Check if user has any content for null state detection
    cache_current_user_content
    @user_has_content = @current_user_content.values.flatten.any?
    
    set_questionable_content # for questions
    generate_dashboard_analytics # for activity chart and streak

    @sidenav_expansion = 'worldbuilding'
  end

  def table_of_contents
    @toc_scope = @universe_scope || current_user
    @toc_user  = @universe_scope.try(:user) || current_user

    # Get content list - handle differently depending on whether we're scoped to a universe or a user
    content_list = if @toc_scope.is_a?(Universe)
      # For a Universe, we need to get content from the user that's in this universe
      user_content = @toc_user.content_list(page_scoping: { user_id: @toc_user.id })
      universe_id = @toc_scope.id
      user_content.select { |page| page['universe_id']&.to_i == universe_id || page['page_type'] == 'Universe' && page['id'] == universe_id }
    else
      # For a User, we can directly use their content_list method
      @toc_scope.content_list
    end

    # Sort the content list by name
    content_list = content_list.sort_by { |page| page['name'] }

    @starred_pages = content_list.select { |page| page['favorite'] == 1 }
    @other_pages   = content_list.select { |page| page['favorite'] == 0 }

    @page_type_counts = Hash.new(0)
    content_list.each { |page| @page_type_counts[page['page_type']] += 1 }
  end

  def infostack
  end

  def sascon
  end

  def paper
    @navbar_color = '#4CAF50'

    @total_notebook_pages   = 0
    @total_pages_equivalent = 0
    @total_trees_saved      = 0

    @per_page_savings = {}

    (Rails.application.config.content_types[:all] + [Timeline, Document]).each do |content_type|
      physical_page_equivalent = GreenService.total_physical_pages_equivalent(content_type)
      tree_equivalent          = physical_page_equivalent.to_f / GreenService::SHEETS_OF_PAPER_PER_TREE

      @per_page_savings[content_type.name] = {
        digital: content_type.last.try(:id) || 0,
        pages:   physical_page_equivalent,
        trees:   tree_equivalent
      }

      @total_notebook_pages   += @per_page_savings.dig(content_type.name, :digital)
      @total_pages_equivalent += @per_page_savings.dig(content_type.name, :pages)
      @total_trees_saved      += @per_page_savings.dig(content_type.name, :trees)
    end
  end

  def prompts
    @sidenav_expansion = 'writing'
    @navbar_color = '#FF9800'
    @page_title = "Writing prompts"

    set_questionable_content # for question
  end

  # deprecated path just kept around for bookmarks for a while
  def notes
    redirect_to edit_document_path(current_user.documents.first)
  end

  def recent_content
    @page_title = "Recent Activity"
    
    # Get base content with enhanced data
    cache_current_user_content
    all_content = @current_user_content.values.flatten

    # Fetch all edit counts in a single query (fixes N+1)
    edit_counts = ContentChangeEvent.where(user_id: current_user.id)
                                    .group(:content_type, :content_id)
                                    .count

    # Add enhanced data to each content item
    @enhanced_content = all_content.map do |content_page|
      edit_count = edit_counts[[content_page.page_type, content_page.id]] || 0

      {
        page: content_page,
        edit_count: edit_count,
        action: content_page.created_at == content_page.updated_at ? 'created' : 'updated',
        days_since_created: (Date.current - content_page.created_at.to_date).to_i,
        days_since_updated: (Date.current - content_page.updated_at.to_date).to_i,
        word_count: content_page.try(:cached_word_count) || 0,
        has_image: content_page.random_image_including_private.present?
      }
    end
    
    # Apply filters
    apply_content_filters
    
    # Apply sorting
    apply_content_sorting
    
    # Generate activity analytics
    generate_activity_analytics
    
    # Pagination
    @page = params[:page]&.to_i || 1
    @per_page = params[:per_page]&.to_i || 24
    @total_pages = (@filtered_content.length.to_f / @per_page).ceil
    @paginated_content = @filtered_content.slice((@page - 1) * @per_page, @per_page) || []
    
    # View mode
    @view_mode = params[:view] || 'grid'
    @view_mode = 'grid' unless %w[grid list timeline].include?(@view_mode)
  end

  private

  def apply_content_filters
    @filtered_content = @enhanced_content
    
    # Search filter
    if params[:search].present?
      search_term = params[:search].downcase
      @filtered_content = @filtered_content.select do |item|
        item[:page].name.downcase.include?(search_term)
      end
    end
    
    # Content type filter
    if params[:content_type].present? && params[:content_type] != 'all'
      @filtered_content = @filtered_content.select do |item|
        item[:page].page_type == params[:content_type]
      end
    end
    
    # Date range filter
    if params[:date_range].present?
      case params[:date_range]
      when 'today'
        @filtered_content = @filtered_content.select { |item| item[:days_since_updated] == 0 }
      when 'week'
        @filtered_content = @filtered_content.select { |item| item[:days_since_updated] <= 7 }
      when 'month'
        @filtered_content = @filtered_content.select { |item| item[:days_since_updated] <= 30 }
      when 'year'
        @filtered_content = @filtered_content.select { |item| item[:days_since_updated] <= 365 }
      end
    end
    
    # Action filter (created vs updated)
    if params[:action_filter].present? && params[:action_filter] != 'all'
      @filtered_content = @filtered_content.select do |item|
        item[:action] == params[:action_filter]
      end
    end
  end

  def apply_content_sorting
    sort_by = params[:sort] || 'updated_at'
    sort_direction = params[:direction] || 'desc'
    
    @filtered_content = @filtered_content.sort_by do |item|
      case sort_by
      when 'name'
        item[:page].name.downcase
      when 'created_at'
        item[:page].created_at
      when 'updated_at'
        item[:page].updated_at
      when 'content_type'
        item[:page].page_type
      when 'edit_count'
        item[:edit_count]
      when 'word_count'
        item[:word_count]
      else
        item[:page].updated_at
      end
    end
    
    @filtered_content.reverse! if sort_direction == 'desc'
  end

  def generate_activity_analytics
    @total_content = @enhanced_content.length
    @total_edits = @enhanced_content.sum { |item| item[:edit_count] }
    @total_words = @enhanced_content.sum { |item| item[:word_count] }
    
    # Content type breakdown
    @content_type_stats = @enhanced_content.group_by { |item| item[:page].page_type }
      .transform_values(&:count)
      .sort_by { |_, count| -count }
    
    # Activity over time (last 7 days for recent content page)
    @daily_activity = (0..6).map do |days_ago|
      date = Date.current - days_ago.days
      activity_count = @enhanced_content.count do |item|
        item[:page].updated_at.to_date == date
      end
      [date.strftime('%m/%d'), activity_count]
    end.reverse
    
    # Most active content types
    @most_active_types = @enhanced_content.group_by { |item| item[:page].page_type }
      .transform_values { |items| items.sum { |item| item[:edit_count] } }
      .sort_by { |_, edits| -edits }
      .first(5)
      
    # Recent activity summary
    @recent_summary = {
      today: @enhanced_content.count { |item| item[:days_since_updated] == 0 },
      this_week: @enhanced_content.count { |item| item[:days_since_updated] <= 7 },
      this_month: @enhanced_content.count { |item| item[:days_since_updated] <= 30 }
    }
  end

  def generate_dashboard_analytics
    return unless user_signed_in?
    
    cache_current_user_content
    all_content = @current_user_content.values.flatten
    
    # 30-Day Activity Chart for Dashboard
    @dashboard_daily_activity = (0..29).map do |days_ago|
      date = Date.current - days_ago.days
      activity_count = all_content.count do |content_page|
        content_page.updated_at.to_date == date
      end
      [date.strftime('%m/%d'), activity_count]
    end.reverse
    
    # Calculate Editing Streak
    calculate_editing_streak(all_content)

    # Use user's timezone for date calculations
    user_today = current_user.current_date_in_time_zone

    # Words written today (actual delta from yesterday)
    @words_written_today = WordCountUpdate.words_written_on_date(current_user, user_today)

    # Daily word goal (max of active goals or default 1,000)
    @daily_word_goal = current_user.daily_word_goal

    # Words written this week (actual delta from end of last week)
    @words_written_this_week = WordCountUpdate.words_written_in_range(
      current_user,
      user_today.beginning_of_week..user_today
    )
  end

  def calculate_editing_streak(all_content)
    # Use user's timezone for date calculations
    user_today = current_user.current_date_in_time_zone

    # Get unique dates when user edited content (last 100 days to be safe)
    edit_dates = all_content.map { |page| page.updated_at.to_date }.uniq.sort.reverse

    # Calculate current streak
    current_streak = 0
    current_date = user_today

    # Check each day going backwards
    while edit_dates.include?(current_date)
      current_streak += 1
      current_date -= 1.day
    end

    @current_streak = current_streak

    # Calculate total edits in current streak
    @streak_total_edits = 0
    if current_streak > 0
      streak_dates = (0..current_streak-1).map { |days_ago| user_today - days_ago.days }
      @streak_total_edits = all_content.count { |page| streak_dates.include?(page.updated_at.to_date) }
    end

    # Generate last 7 days for streak visualization
    @streak_days = (0..6).map do |days_ago|
      date = user_today - days_ago.days
      has_activity = edit_dates.include?(date)
      edit_count = all_content.count { |page| page.updated_at.to_date == date }
      {
        date: date,
        has_activity: has_activity,
        edit_count: edit_count,
        day_name: date.strftime('%a')[0] # First letter of day name
      }
    end.reverse
  end

  def for_writers
    @page_title = "Creating fictional worlds and everything within them"
  end

  def for_roleplayers
    @page_title = "Building campaigns and everything within them"
  end

  def feature_voting
  end

  def privacyinfo
    @sidenav_expansion = 'my account'
  end

  private

  def set_questionable_content
    content_pool = @current_user_content.except(*%w(Timeline Document)).values.flatten.shuffle

    # Try to find content with an unanswered question
    content_pool.each do |content|
      question = SerendipitousService.question_for(content)
      if question.present?
        @content = content
        @attribute_field_to_question = question
        return
      end
    end

    # No unanswered questions found - set flags for empty state
    @content = nil
    @attribute_field_to_question = nil
  end

  def set_page_meta_tags
    set_meta_tags(
      site: "The smart notebook for worldbuilders - Notebook.ai",
      page: ''
    )
  end
end
