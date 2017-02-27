class Siblingship < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :character
  belongs_to :sibling, class_name: 'Character'

  def self.after_add_handler x
    raise x.inspect
    raise self.instance_of?(Siblingship)
    return unless [self.sibling_id, self.character_id].all?(&:present?)

    # todo: Character => link.class_name.find_by(id: link.name, user_id: self.user_id)
    related_content = Character.find_by(id: self.sibling_id, user_id: self.character.user.id)

    if related_content
      # mutual link: if it's not already added both ways, add it both ways
      # could maybe use class name (siblingships) instead of link name (siblings) here
      return if related_content.siblings.pluck(:id).include? self.character_id

      related_content.siblings << self.character
      related_content.save
    end
  end

  # def mutual_destroy
  #   # This handles when the link is removed from one object but not the other in a mutual link:
  #   # we want to also remove it from the other object, if it's set on it
  #   related_content = Character.find_by(id: self.sibling_id, user_id: self.character.user.id)

  #   if related_content
  #     # If it's not set on the related content, there's no need to remove it
  #     return unless related_content.siblings.pluck(:id).include? self.sibling_id

  #     related_content.siblings.delete(related_content.id)
  #     related_content.save
  #   end
  # end
end
