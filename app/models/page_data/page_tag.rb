class PageTag < ApplicationRecord
  belongs_to :page, polymorphic: true
  belongs_to :user

  after_update :update_slug_to_reflect_label_changes

  # Delimiter to be used wherever we want to allow submitting multiple tags in a single string
  SUBMISSION_DELIMITER = ',,,|||,,,'

  def to_s
    self.tag
  end

  def self.icon
    'label'
  end

  def update_slug_to_reflect_label_changes
    self.update_slug! if (saved_change_to_tag? && self.tag.present?)
  end

  def update_slug!
    new_slug = PageTagService.slug_for(self.tag)
    self.update(slug: new_slug) unless new_slug == self.slug
  end
end
