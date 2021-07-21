class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action :set_universe_session
  before_action :set_universe_scope

  before_action :cache_most_used_page_information
  before_action :cache_forums_unread_counts

  before_action :set_metadata

  def content_type_from_controller(content_controller_name)
    content_controller_name.to_s.chomp('Controller').singularize.constantize
  end

  private

  def set_metadata
    @page_title       ||= ''
    @page_keywords    ||= %w[writing author nanowrimo novel character fiction fantasy universe creative dnd roleplay game design]
    @page_description ||= 'Notebook.ai is a set of tools for writers, game designers, and roleplayers to create magnificent universes — and everything within them.'
  end

  def set_universe_session
    if params[:universe].present? && user_signed_in?
      if params[:universe] == 'all'
        session.delete(:universe_id)
      elsif params[:universe].is_a?(String) && params[:universe].to_i.to_s == params[:universe]
        found_universe = Universe.find_by(id: params[:universe])
        found_universe = nil unless current_user.universes.include?(found_universe) || current_user.contributable_universes.include?(found_universe)
        session[:universe_id] = found_universe.id if found_universe
      end
    end
  end

  def set_universe_scope
    if user_signed_in? && session.key?(:universe_id)
      @universe_scope = Universe.find_by(id: session[:universe_id])
      @universe_scope = nil unless current_user.universes.include?(@universe_scope) || current_user.contributable_universes.include?(@universe_scope)
    else
      @universe_scope = nil
    end
  end

  # Cache some super-common stuff we need for every page. For example, content lists for the side nav.
  def cache_most_used_page_information
    @current_user_content = {}
    return unless user_signed_in?

    @activated_content_types = (
      Rails.application.config.content_types[:all].map(&:name) & # Use config to dictate order, but AND to only include what a user has turned on
      current_user.user_content_type_activators.pluck(:content_type)
    )

    # We always want to cache Universes, even if they aren't explicitly turned on.
    @current_user_content = current_user.content(content_types: @activated_content_types + ['Universe'], universe_id: @universe_scope.try(:id))

    # Likewise, we should also always cache Timelines & Documents
    if @universe_scope
      @current_user_content['Timeline'] = current_user.timelines.where(universe_id: @universe_scope.try(:id)).to_a
      @current_user_content['Document'] = current_user.linkable_documents.includes([:user]).where(universe_id: @universe_scope.try(:id)).order('updated_at DESC').to_a
    else
      @current_user_content['Timeline'] = current_user.timelines.to_a
      @current_user_content['Document'] = current_user.linkable_documents.includes([:user]).order('updated_at DESC').to_a
    end

    # Fetch notifications
    @user_notifications = current_user.notifications.order('happened_at DESC').limit(100)

    # Cache recently-edited pages
    @recently_edited_pages = @current_user_content.values.flatten
      .sort_by(&:updated_at)
      .last(50)
      .reverse
  end

  def cache_forums_unread_counts
    @unread_threads = if user_signed_in?
      Thredded::Topic.unread_followed_by(current_user).count
    else
      0
    end

    @unread_private_messages = if user_signed_in?
      Thredded::PrivateTopic
        .for_user(current_user)
        .unread(current_user)
        .count
    else
      0
    end
  end

  def cache_linkable_content_for_each_content_type
    return unless user_signed_in?

    linkable_classes = Rails.application.config.content_type_names[:all] & current_user.user_content_type_activators.pluck(:content_type)
    linkable_classes += %w(Document Timeline)

    # TODO: why can't we just use @current_user_content here?

    @linkables_cache = {}
    @linkables_raw   = {}
    linkable_classes.each do |class_name|
      # class_name = "Character"

      @linkables_cache[class_name] ||= current_user
        .send("linkable_#{class_name.downcase.pluralize}")
        .in_universe(@universe_scope)

      if @content.present? && @content.persisted?
        @linkables_cache[class_name] = @linkables_cache[class_name]
          .in_universe(@content.universe)
          .reject { |content| content.class.name == class_name && content.id == @content.id }
      end

      @linkables_raw[class_name] ||= @linkables_cache[class_name]
        .sort_by { |p| p.name.downcase }
        .compact

      @linkables_cache[class_name] = @linkables_cache[class_name]
        .sort_by { |p| p.name.downcase }
        .map { |c| [c.name, c.id] }
        .compact
    end
  end
end
