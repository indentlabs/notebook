class ConversationController < ApplicationController
  before_action :set_character
  before_action :ensure_character_privacy

  def character_landing
    @first_greeting = "Hello, friend!"

    @personality = personality_for_character
    @description = description_for_character
  end

  def export
    raise open_characters_persona_params.inspect
  end

  private

  def personality_for_character
    name    = @character.name
    gender  = @character.get_field_value('Overview', 'Gender')
    role    = @character.get_field_value('Overview', 'Role')
    age     = @character.get_field_value('Overview', 'Age')
    aliases = @character.get_field_value('Overview', 'Aliases')
    hobbies = @character.get_field_value('Nature',   'Hobbies')

    [
      name,
      " is a ",
      gender.downcase,
      " ",
      role || "character",
      age.present?     ? ", #{age},"                  : nil,
      aliases.present? ? "(also known as #{aliases})" : nil,
      hobbies.present? ? " into #{hobbies}."          : "."
    ].compact.join
  end

  def description_for_character
    occupation  = @character.get_field_value('Social', 'Occupation')
    background  = @character.get_field_value('History', 'Background')
    motivations = @character.get_field_value('Nature', 'Motivations')
    mannerisms  = @character.get_field_value('Nature', 'Mannerisms')
    flaws       = @character.get_field_value('Nature', 'Flaws')
    prejudices  = @character.get_field_value('Nature', 'Prejudices')
    talents     = @character.get_field_value('Nature', 'Talents')
    hobbies     = @character.get_field_value('Nature', 'Hobbies')
    
    description_parts = []
    description_parts.concat ["OCCUPATION", occupation, nil] if occupation.present?
    description_parts.concat ["BACKGROUND", background, nil] if background.present?
    description_parts.concat ["MOTIVATIONS", motivations, nil] if motivations.present?
    description_parts.concat ["MANNERISMS", mannerisms, nil] if mannerisms.present?
    description_parts.concat ["FLAWS", flaws, nil] if flaws.present?
    description_parts.concat ["PREJUDICES", prejudices, nil] if prejudices.present?
    description_parts.concat ["TALENTS", talents, nil] if talents.present?
    description_parts.concat ["HOBBIES", hobbies, nil] if hobbies.present?

    description_parts.join("\n")
  end

  def set_character
    @character = Character.find(params[:character_id].to_i)
  end

  def ensure_character_privacy
    unless (user_signed_in? && @character.user == current_user) || @character.privacy == 'public'
      redirect_to root_path, notice: "That character is private!"
    end
  end

  def open_characters_persona_params
    params.permit(:name, :avatar, :scenario, :char_greeting, :personality, :description, :example_dialogue)
  end
end
