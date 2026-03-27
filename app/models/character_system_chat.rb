class CharacterSystemChat < ApplicationRecord
  belongs_to :character
  belongs_to :user, optional: true

  before_create :set_uid

  def set_uid
    self.uid ||= SecureRandom.uuid
  end
end
