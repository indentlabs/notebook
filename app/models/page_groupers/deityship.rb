class Deityship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true
  belongs_to :religion

  # This is hacky because we had Deityships pointing at character "deities" before
  # actually having deity models. When we added a ReligionDeityship that points to
  # a deity "deity", this got renamed to "deity_character" and we needed this
  # foreign key / alias.
  belongs_to :deity_character, class_name: 'Character', foreign_key: 'deity_id', optional: true
  def deity_character_id
    deity_id
  end

  def deity_character_id=(x)
    self.deity_id = x
  end
end
