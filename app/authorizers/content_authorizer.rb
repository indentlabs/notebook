class ContentAuthorizer < ApplicationAuthorizer
  def readable_by? user
  	[
      resource.user_id == user.id,
      resource.privacy == 'public',
      resource.universe.present? && resource.universe.privacy == 'public'
 	].any?
  end

  def updatable_by? user
  	#todo: Collaboration
  	resource.user_id == user.id
  end

  def deletable_by? user
  	#todo: Collaboration
  	resource.user_id == user.id
  end
end
