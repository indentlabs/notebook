class ConversationController < ApplicationController
  before_action :set_character
  before_action :ensure_character_privacy

  def character_landing
    @first_greeting = default_character_greeting
    @personality    = personality_for_character
    @description    = description_for_character
  end

  def export
    name        = open_characters_persona_params.fetch('name', 'New character').strip
    personality = open_characters_persona_params.fetch('personality', '')
    description = open_characters_persona_params.fetch('description', '')

    add_character_hash = base_open_characters_export.merge({
      "name":            name,
      "roleInstruction": "You are to act as #{name}, whos personality is detailed below:\n\n#{description}",
      "reminderMessage": "#{personality}\n\nDo not break character!",
    })

    # Add a character image if one has been uploaded to the page
    avatar = @character.random_image_including_private
    add_character_hash[:avatar][:url] = avatar if avatar.present?

    # Redirect to OpenCharacters
    base_oc_url = 'https://josephrocca.github.io/OpenCharacters/'
    oc_params = { addCharacter: add_character_hash }

    redirect_to "#{base_oc_url}##{ERB::Util.url_encode(oc_params.to_json)}"
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
      return
    end
  end

  def open_characters_persona_params
    params.permit(:name, :avatar, :scenario, :char_greeting, :personality, :description, :example_dialogue)
  end

  def default_scenario
    ""
  end

  def default_reminder_message
    ""
  end

  def default_custom_code
    ""

    # TODO maybe include our standard (whisper) formatting on messages?
  end

  def base_open_characters_export
    {
      "name": "New character",
      # "roleInstruction": default_scenario,
      # "reminderMessage": default_reminder_message,
      "modelName": "gpt-3.5-turbo",
      "fitMessagesInContextMethod": "summarizeOld",
      "associativeMemoryMethod": "v1",
      "associativeMemoryEmbeddingModelName": "text-embedding-ada-002",
      "temperature": 0.7,
      "customCode": default_custom_code,
      "initialMessages": default_initial_messages,
      "avatar": {
        "url": "",
        "size": 1,
        "shape": "square"
      },
      "scene": {
        "background": {
          "url": ""
        },
        "music": {
          "url": ""
        }
      },
      "userCharacter": {
        "avatar": {
          "url": current_user.avatar.url,
          "size": 1,
          "shape": "circle"
        }
      },
      "streamingResponse": true
    }
  end

  def default_initial_messages
    [
      {
        "author": "system",
        "content": open_characters_persona_params.fetch('scenario', default_scenario),
        "hiddenFrom": [] # "ai", "user", "both", "neither"
      },
      {
        "author": "ai",
        "content": open_characters_persona_params.fetch('char_greeting', default_character_greeting),
        "hiddenFrom": []
      }
    ]
  end

  def default_export_metadata
    {
      "version":  1,
      "created":  @content.created_at.to_i,
      "modified": @content.updated_at.to_i,
      "ncid":     @content.id,
      "source": "https://www.notebook.ai/plan/characters#{@content.id}",
      "tool": {
        "name": "Notebook.ai Persona Export",
        "version": "1.0.0",
        "url": "https://www.notebook.ai"
      }
    }
  end

  def default_character_greeting
    "Hello, friend!"
  end
end
