class GenerateCharacterChatResponseJob < ApplicationJob
  queue_as :default

  def perform(chat_id)
    chat = CharacterSystemChat.find_by(id: chat_id)
    return unless chat

    # Extract messages to send to the API.
    # The API expects [{ role: 'system|user|ai', content: '...' }]
    api_messages = chat.messages.map do |m|
      { role: m['role'], content: m['content'] }
    end

    service = TextGenerationService.new(messages: api_messages)
    result = service.call

    if result[:success]
      chat.messages << { 'role' => 'ai', 'content' => result[:content], 'timestamp' => Time.current.to_f }
      chat.touch
      chat.save
    else
      # If there's an error, inform the user with a system message
      error_msg = "The character could not reply due to a connection error. Please try sending a new message."
      chat.messages << { 'role' => 'system', 'content' => error_msg, 'timestamp' => Time.current.to_f }
      chat.touch
      chat.save
    end
  end
end
