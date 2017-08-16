class ContentAuthorizer < ApplicationAuthorizer
  def readable_by? user
    [
      resource.user_id == user.id,
      resource.respond_to?(:privacy) && resource.privacy == 'public',
      resource.universe.present? && resource.universe.privacy == 'public',
      resource.universe.present? && user.contributable_universes.pluck(:id).include?(resource.universe.id)
    ].any?
  end

  def updatable_by? user
    [
      resource.universe && user.contributable_universes.pluck(:id).include?(resource.universe.id),
      resource.universe.nil? && resource.user_id == user.id,
    ].any?
  end

  def deletable_by? user
    [
      resource.universe && resource.universe.user == user.id,
      resource.universe.nil? && resource.user_id == user.id
    ].any?
  end
end
