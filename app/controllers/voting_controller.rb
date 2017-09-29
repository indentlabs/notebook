class VotingController < ApplicationController
  def vote
    if !user_signed_in? || current_user.votes.where(votable_id: nil).count < 1
      redirect_to community_voting_path
      return
    end

    votable = Votable.find(params[:id])
    if votable.nil?
      redirect_to community_voting_path
      return
    end

    vote_to_cast = current_user.votes.where(votable_id: nil).first
    vote_to_cast.update votable_id: votable.id
    redirect_to community_voting_path, notice: "You voted for #{votable.name} successfully!"
  end
end
