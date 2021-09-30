class ContributorsController < ApplicationController
  def destroy
    contributor = Contributor.find(params[:id])
    relevant_universe = Universe.find(contributor.universe_id)

    if contributor
      user = contributor.user
      contributor.destroy

      # Create a notification letting the user know!
      user.notifications.create(
        message_html:     "<div>You have been removed as a contributor from the <span class='#{Universe.text_color}'>#{relevant_universe.name}</span> universe.</div>",
        icon:             Universe.icon,
        icon_color:       Universe.color,
        happened_at:      DateTime.current,
        passthrough_link: Rails.application.routes.url_helpers.universe_path(relevant_universe)
      ) if user.present?

      # Create a notification letting the universe owner know
      relevant_universe.user.notifications.create(
        message_html:     "<div><span class='#{User.text_color}'>#{user.display_name}</span> has stopped collaborating on your <span class='#{Universe.text_color}'>#{relevant_universe.name}</span> universe.</div>",
        icon:             Universe.icon,
        icon_color:       Universe.color,
        happened_at:      DateTime.current,
        passthrough_link: Rails.application.routes.url_helpers.universe_path(relevant_universe)
      ) if user.present?

      #todo send "you've been removed as a contributor" email
    end

    # A 303 status is required here so the browser doesn't redirect with a DELETE action
    # https://stackoverflow.com/questions/14598703/rails-redirect-after-delete-using-delete-instead-of-get
    redirect_to universes_path, status: 303
  end
end
