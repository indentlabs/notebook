class ContributorsController < ApplicationController
  before_action :authenticate_user!
  
  def create
    universe = Universe.find(params[:universe_id])
    
    # Check if the current user is the owner of the universe
    unless universe.user_id == current_user.id
      redirect_to edit_universe_path(universe, anchor: 'contributors'), alert: 'Only the universe owner can add contributors.'
      return
    end
    
    email = params[:contributor][:email]&.downcase
    
    # Check if this email is already a contributor
    if universe.contributors.exists?(email: email)
      redirect_to edit_universe_path(universe, anchor: 'contributors'), alert: 'This user is already a contributor.'
      return
    end
    
    # Use the ContributorService to handle the invitation
    ContributorService.invite_contributor_to_universe(universe: universe, email: email)
    
    redirect_to edit_universe_path(universe, anchor: 'contributors'), notice: 'Contributor invitation sent!'
  rescue StandardError => e
    redirect_to edit_universe_path(universe, anchor: 'contributors'), alert: 'Failed to add contributor. Please try again.'
  end
  
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
        passthrough_link: Rails.application.routes.url_helpers.universe_path(relevant_universe),
        reference_code:   'contributor-removed'
      ) if user.present?

      # Create a notification letting the universe owner know
      relevant_universe.user.notifications.create(
        message_html:     "<div><span class='#{User.text_color}'>#{user.display_name}</span> has stopped collaborating on your <span class='#{Universe.text_color}'>#{relevant_universe.name}</span> universe.</div>",
        icon:             Universe.icon,
        icon_color:       Universe.color,
        happened_at:      DateTime.current,
        passthrough_link: Rails.application.routes.url_helpers.universe_path(relevant_universe),
        reference_code:   'contributor-left'
      ) if user.present?

      #todo send "you've been removed as a contributor" email
    end

    # Set a flash message for feedback
    if user.present? && user.id == current_user.id
      # User removed themselves
      flash[:notice] = "You have left the universe '#{relevant_universe.name}'"
    else
      # Owner removed a contributor
      flash[:notice] = "Contributor removed successfully"
    end

    # A 303 status is required here so the browser doesn't redirect with a DELETE action
    # https://stackoverflow.com/questions/14598703/rails-redirect-after-delete-using-delete-instead-of-get
    # Redirect back to the universe edit page with contributors anchor
    redirect_to edit_universe_path(relevant_universe, anchor: 'contributors'), status: 303
  end
end
