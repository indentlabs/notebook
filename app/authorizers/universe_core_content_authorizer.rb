class UniverseCoreContentAuthorizer < CoreContentAuthorizer
  def self.creatable_by? user
  	true
  end

  def readable_by? user
    [
      resource.user_id == user.id,
      resource.privacy == 'public'
 	].any?
  end

  def updatable_by? user
  	resource.user_id == user.id
  end

  def deletable_by? user
  	resource.user_id == user.id
  end
end
