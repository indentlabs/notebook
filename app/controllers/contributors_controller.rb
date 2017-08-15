class ContributorsController < ApplicationController
  def destroy
    contributor = Contributor.find(params[:id])
    relevant_universe = Universe.find(contributor.universe_id)

    if contributor
      contributor.destroy

      #todo send "you've been removed as a contributor" email
    end

    # A 303 status is required here so the browser doesn't redirect with a DELETE action
    # https://stackoverflow.com/questions/14598703/rails-redirect-after-delete-using-delete-instead-of-get
    redirect_to universes_path, status: 303
  end
end
