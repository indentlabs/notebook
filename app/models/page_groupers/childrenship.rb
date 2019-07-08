class Childrenship < ApplicationRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :character
  belongs_to :child, class_name: 'Character'

  # These values are used for detecting whether a related character is a male or female
  #todo: proper gender extraction
  MALE_VALUES   = ['male', 'male.', 'm', 'man', 'guy', 'dude', 'patern', 'father']
  FEMALE_VALUES = ['female', 'female.', 'f', 'woman', 'lady', 'gal', 'dudette', 'matern', 'matriarch', 'mother']

  after_create do
    this_object  = Character.find_by(id: self.character_id)
    other_object = Character.find_by(id: self.child_id)

    if other_object.present?
      # If this character is marked having a child, we need to figure out whether it's the father or mother
      # of that child and create the proper association
      gender = gender_of_object this_object
      if gender == :male
        other_object.fatherships.create(character: other_object, father: this_object) unless other_object.fathers.include?(this_object)

      elsif gender == :female
        other_object.motherships.create(character: other_object, mother: this_object) unless other_object.mothers.include?(this_object)

      end
    end
  end

  after_destroy do
    # This is a two-way relation, so we should also delete the reverse association
    this_object  = Character.find_by(id: self.character_id)
    other_object = Character.find_by(id: self.child_id)

    # If there's no linked object to modify, what are we even doing here?
    if other_object.present?
      gender = gender_of_object(this_object)
      if gender == :male
        other_object.fathers.delete(this_object)

      elsif gender == :female
        other_object.mothers.delete(this_object)

      elsif gender.nil?
        if other_object.fathers.include?(this_object)
          other_object.fathers.delete(this_object)

        elsif other_object.mothers.include?(this_object)
          other_object.mothers.delete(this_object)
        end
      end
    end
  end

  # todo: move this somewhere more reusable
  def gender_of_object object
    return nil     if object.gender.nil?
    return :male   if MALE_VALUES.include? object.gender.downcase
    return :female if FEMALE_VALUES.include? object.gender.downcase
  end
end
