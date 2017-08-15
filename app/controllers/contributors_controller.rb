class ContributorsController < ApplicationController
  def destroy
    contributor = Contributor.find(params[:id])

    if contributor
      contributor.destroy

      #todo send "you've been removed as a contributor" email
    end
  end
end
