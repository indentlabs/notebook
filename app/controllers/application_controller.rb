# frozen_string_literal: true
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
        found_universe = nil unless found_universe.user_id == current_user.id || found_universe.contributors.pluck(:user_id).include?(current_user.id)
        session[:universe_id] = found_universe.id if found_universe
      end
    end
  end

  def set_universe_scope
    if user_signed_in? && session.key?(:universe_id)
      @universe_scope = Universe.find_by(id: session[:universe_id])

      if @universe_scope && @universe_scope.user_id != current_user.try(:id)
        # Verify the current user has access to this universe by looking up their
        # universe contributorship
        contributorship = Contributor.find_by(
          user:     current_user,
          universe: @universe_scope
        )

        if contributorship.nil?
          # If the user doesn't have current contributor access to this universe,
          # then revert back to unscoped universe actions
          @universe_scope = nil
        end
      end

    else
      @universe_scope = nil
    end
  end

  # Cache some super-common stuff we need for every page. For example, content lists for the side nav. This is a catch-all for most pages that render
  # UI, but methods are also free to skip this filter and call the individual cache methods they need instead.
  def cache_most_used_page_information
    return unless user_signed_in?

    cache_activated_content_types
    cache_current_user_content
    cache_notifications
    cache_recently_edited_pages
  end

  def cache_activated_content_types
    @activated_content_types ||= if user_signed_in?
      (
        # Use config to dictate order, but AND to only include what a user has turned on
        Rails.application.config.content_type_names[:all] & current_user.user_content_type_activators.pluck(:content_type)
      )
    else
      []
    end
  end

  def cache_current_user_content
    return if @current_user_content

    @current_user_content = {}
    return unless user_signed_in?

    cache_activated_content_types

    # We always want to cache Universes, even if they aren't explicitly turned on.
    @current_user_content = current_user.content(
      content_types: @activated_content_types + [Universe.name], 
      universe_id:   @universe_scope.try(:id)
    )

    # Due to the way we loop over @current_user_content (page, list) later, we want to make sure that we
    # at least have an empty list for all activated content types -- otherwise we may skip over the contributor
    # content injection for a type that a user doesn't have ANY pages for.
    @activated_content_types.each do |content_type|
      @current_user_content[content_type] ||= []
    end

    # Likewise, we should also always cache Timelines & Documents
    if @universe_scope
      @current_user_content['Timeline'] = current_user.timelines.where(universe_id: @universe_scope.try(:id)).to_a
      @current_user_content['Document'] = current_user.documents.where(universe_id: @universe_scope.try(:id)).order('updated_at DESC').to_a
    else
      @current_user_content['Timeline'] = current_user.timelines.to_a
      @current_user_content['Document'] = current_user.documents.order('updated_at DESC').to_a
    end
  end

  def cache_notifications
    @user_notifications ||= if user_signed_in?
      current_user.notifications.order('happened_at DESC').limit(100)
    else
      []
    end
  end

  def cache_recently_created_pages(amount=50)
    cache_current_user_content

    @recently_created_pages = if user_signed_in?
      @current_user_content.values.flatten
        .sort_by(&:created_at)
        .last(amount)
        .reverse
    else
      []
    end
  end

  def cache_recently_edited_pages(amount=50)
    cache_current_user_content

    @recently_edited_pages ||= if user_signed_in?
      @current_user_content.values.flatten
        .sort_by(&:updated_at)
        .last(amount)
        .reverse
    else
      []
    end
  end

  def cache_forums_unread_counts
    @unread_threads ||= if user_signed_in?
      Thredded::Topic.unread_followed_by(current_user).count
    else
      0
    end

    @unread_private_messages ||= if user_signed_in?
      Thredded::PrivateTopic
        .for_user(current_user)
        .unread(current_user)
        .count
    else
      0
    end
  end

  def cache_contributable_universe_ids
    cache_current_user_content

    @contributable_universe_ids ||= if user_signed_in?
      current_user.contributable_universe_ids
    else
      []
    end
  end

  def cache_linkable_content_for_each_content_type
    cache_contributable_universe_ids
    cache_current_user_content
    
    linkable_classes = @activated_content_types
    linkable_classes += %w(Document Timeline)

    @linkables_cache = {} # Cache is list of [[page_name, page_id], [page_name, page_id], ...]
    @linkables_raw   = {} # Raw is list of objects [#{page}, #{page}, ...]

    @current_user_content.each do |page_type, content_list|
      # We already have our own list of content by the current user in @current_user_content,
      # so all we need to grab is additional pages in contributable universes
      @linkables_raw[page_type] = @current_user_content[page_type]

      # Add contributor content
      if @contributable_universe_ids.any?
        existing_page_ids = @linkables_raw[page_type].map(&:id)

        pages_to_add = if page_type == Universe.name
          page_type.constantize.where(id: @contributable_universe_ids)
                               .where.not(id: existing_page_ids)
                               .where.not(user_id: current_user.id)
        else
          page_type.constantize.where(universe_id: @contributable_universe_ids)
                               .where.not(id: existing_page_ids)
                               .where.not(user_id: current_user.id)
        end

        # If we're scoped to a universe, also scope contributor content pulled to that
        # universe. If we're not, leave it as all contributor content.
        if @universe_scope && pages_to_add.klass.name != 'Universe'
          pages_to_add = pages_to_add.where(universe: @universe_scope)
        end

        filtered_fields = ContentPage.polymorphic_content_fields.map(&:to_s)
        filtered_fields.push 'universe_id' unless page_type == Universe.name
        pages_to_add.each do |page_data|
          filtered_page_data = page_data.attributes.slice(*filtered_fields)
          @linkables_raw[page_type].push ContentPage.new(filtered_page_data)
        end
      end

      # We can't properly display or @-mention content without a name set, so we explicitly
      # reject it here. However, this is a bit of a code-smell: why is there content without
      # a name set?
      @linkables_raw[page_type].reject!  { |page| page.name.nil? }

      # Finally, we want to sort our linkables cache once so we don't have to sort it again
      @linkables_raw[page_type].sort_by! { |page| page.name.downcase }.compact!

      # Lastly, build our name/id cache as well
      @linkables_cache[page_type] = @linkables_raw[page_type].map { |page| [page.name, page.id] }
    end
  end
end
