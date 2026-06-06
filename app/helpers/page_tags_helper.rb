module PageTagsHelper
  # Builds a path to a user's public tag page, falling back to the ID-based
  # route for legacy users who have no username set. Using user_tag_path
  # directly with a nil username raises ActionController::UrlGenerationError,
  # so all "link to this user's tag page" call sites should go through here.
  def user_tag_path_for(user, tag_slug)
    if user&.username.present?
      user_tag_path(username: user.username, tag_slug: tag_slug)
    else
      user_id_tag_path(id: user.id, tag_slug: tag_slug)
    end
  end
end
