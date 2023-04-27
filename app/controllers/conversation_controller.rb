class ConversationController < ApplicationController
  before_action :authenticate_user!,       only: [:character_index]

  before_action :set_character,            only: [:character_landing, :export]
  before_action :ensure_character_privacy, only: [:character_landing, :export]

  def character_index
    @characters = @current_user_content.fetch('Character', [])
  end

  def character_landing
    @first_greeting = default_character_greeting
    @personality    = personality_for_character
    @description    = description_for_character
  end

  def export
    name        = open_characters_persona_params.fetch('name', 'New character').strip
    description = open_characters_persona_params.fetch('description', '')

    add_character_hash = base_open_characters_export.merge({
      "uuid":            deterministic_uuid(@character.id),
      "name":            name,
      "roleInstruction": full_role_instruction,
      "reminderMessage": reminder_message,
    })

    # Add a character image if one has been uploaded to the page
    avatar = @character.random_image_including_private
    add_character_hash[:avatar][:url] = avatar if avatar.present?

    # Provide a default scenario if one wasn't given
    add_character_hash[:scenario] ||= default_scenario

    # Redirect to OpenCharacters
    base_oc_url = 'https://josephrocca.github.io/OpenCharacters/'
    oc_params = { addCharacter: add_character_hash }

    redirect_to "#{base_oc_url}##{ERB::Util.url_encode(oc_params.to_json)}"
  end

  private

  def deterministic_uuid(id)
    static_prefix = "notebook-"
    hashed_id = Digest::SHA1.hexdigest(static_prefix + id.to_s)
    uuid = "#{hashed_id[0..7]}-#{hashed_id[8..11]}-#{hashed_id[12..15]}-#{hashed_id[16..19]}-#{hashed_id[20..31]}"
    uuid
  end

  def full_role_instruction
    final_text = [
      "[SYSTEM]: You are roleplaying as #{@character.name}, #{personality_for_character}",
      "",
      "Follow this pattern:",
      "\"Hello!\" - dialogue",
      "*He jumps out of the bushes.* - action",
      "",
      "#{@character.name}'s personality is below:",
      "#{open_characters_persona_params.fetch('description', '(not included)')}",
      "",
      "#{@character.name} will now respond while staying in character in an extremely descriptive manner at length, avoiding being repetitive, without advancing events by herself, avoiding implying conversations without a reply from the user first, and wait for the user's reply to advance events. Describe what #{@character.name} is feeling, saying, and doing with rich detail, but do not include any parenthetical thoughts and focus primarily on dialogue.",
    ].join("\n")
  end

  def reminder_message
    "[SYSTEM]: (Thought: I need to rememeber to be creative, descriptive, and engaging! I should work very hard to avoid being repetitive as well! Unless the user speaks to me OOC, with parentheses around their input, first, I will not say anything OOC or in parentheses. I shouldn't ignore parts of the user's post, even if they move on to a new scene. I should at least write my characters thoughts and feelings towards the prior scene before continuing with the new one. I don't need to feel the need to write a long response if the user's post is short. In that case, I can feel free to write a short response myself - making sure to not take over writing the user's character's dialogue, thoughts, or actions!)"
  end

  def personality_for_character
    hobbies = @character.get_field_value('Nature', 'Hobbies')

    personality_parts = [
      "a #{@character.get_field_value('Overview', 'Gender', fallback='')} #{@character.get_field_value('Overview', 'Role', fallback='character')}, age #{@character.get_field_value('Overview', 'Age', fallback='irrelevant')}."
    ]
    personality_parts << "Their hobbies include #{hobbies}." if hobbies.present?

    ContentFormatterService.plaintext_show(text: personality_parts.join(' '), viewing_user: current_user)
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

    ContentFormatterService.plaintext_show(text: description_parts.join("\n"), viewing_user: current_user)
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
    "This character is interacting with the user within their own fictional universe. The character will respond in a way that is consistent with their personality and background."
  end

  def default_custom_code
    ""

    # TODO maybe include our standard (whisper) formatting on messages?
  end

  def base_open_characters_export
    {
      "name": "New character",
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
        "content": "Scenario: " + (open_characters_persona_params.fetch('scenario', nil).presence || default_scenario),
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
    "Hello!"
  end
end
