class CharacterChatsController < ApplicationController
  before_action :authenticate_user!,       only: [:index, :show, :create, :message, :latest]
  before_action :set_character
  before_action :ensure_character_privacy
  before_action { @navbar_color = Character.hex_color }

  def index
    @chats = CharacterSystemChat.where(user: current_user).includes(:character).order(updated_at: :desc)
    
    # If no chats exist, auto-create one and redirect
    if @chats.empty?
      create
    else
      # Otherwise just load the most recent chat, or render an index
      redirect_to character_chat_path(@character.id, @chats.first.uid)
    end
  end

  def create
    @chat = CharacterSystemChat.new(character: @character, user: current_user)
    
    # Initialize the chat with the system prompt and greeting
    @chat.messages = default_initial_messages
    @chat.save!

    redirect_to character_chat_path(@character.id, @chat.uid)
  end

  def show
    @chat = CharacterSystemChat.find_by!(uid: params[:uid], character: @character)
    @chats = CharacterSystemChat.where(user: current_user).includes(:character).order(updated_at: :desc)
    @chat.touch # Bump updated_at so it stays at the top of the sidebar
  end

  def destroy
    @chat = CharacterSystemChat.find_by!(uid: params[:uid], character: @character, user: current_user)
    @chat.destroy
    redirect_to talk_path(@character.id), notice: 'Conversation deleted.'
  end

  def message
    @chat = CharacterSystemChat.find_by!(uid: params[:uid], character: @character)

    # Append the user's message
    user_content = params[:content]
    if user_content.present?
      @chat.messages << {
        'role' => 'user',
        'content' => user_content,
        'timestamp' => Time.current.to_f
      }
      @chat.save!
      
      # Enqueue the background job to fetch the AI's response
      GenerateCharacterChatResponseJob.perform_later(@chat.id)
    end

    head :accepted
  end

  def latest
    @chat = CharacterSystemChat.find_by!(uid: params[:uid], character: @character)
    
    # We want to return messages since a certain timestamp to avoid re-rendering everything
    since = params[:since].to_f
    new_messages = @chat.messages.select { |m| m['timestamp'].to_f > since }
    
    render json: { messages: new_messages }
  end

  private

  def set_character
    @character = Character.find(params[:character_id])
  end

  def ensure_character_privacy
    unless (user_signed_in? && @character.user == current_user) || @character.privacy == 'public'
      redirect_to root_path, notice: "That character is private!"
      return
    end
  end

  # ========================================================================
  # Persona / Context Construction (Migrated from ConversationController)
  # ========================================================================

  def default_initial_messages
    [
      {
        "role" => "system",
        "content" => full_role_instruction,
        "timestamp" => Time.current.to_f
      },
      {
        "role" => "ai", # OpenAI uses 'assistant', but mapping can happen in the service if needed. Using 'ai' locally.
        "content" => "Hello!",
        "timestamp" => (Time.current + 1.second).to_f
      }
    ]
  end

  def full_role_instruction
    final_text = [
      "You are roleplaying as #{@character.name}, #{personality_for_character}",
      "",
      "Follow this pattern:",
      "\"Hello!\" - dialogue",
      "*He jumps out of the bushes.* - action",
      "",
      "#{@character.name}'s personality is below:",
      "#{description_for_character}",
      "",
      "#{@character.name} will now respond while staying in character in an extremely descriptive manner at length, avoiding being repetitive, without advancing events by herself, avoiding implying conversations without a reply from the user first, and wait for the user's reply to advance events. Describe what #{@character.name} is feeling, saying, and doing with rich detail, but do not include any parenthetical thoughts and focus primarily on dialogue."
    ].join("\n")
    final_text
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
end
