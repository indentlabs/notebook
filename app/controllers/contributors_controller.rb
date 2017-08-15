class ContributorsController < ApplicationController
  def destroy
    contributor = Contributor.find(params[:id])

    if contributor
      contributor.destroy

      #todo send "you've been removed as a contributor" email
    end

    #redirect_to :back
  end
end
