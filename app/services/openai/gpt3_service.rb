module Openai
  class Gpt3Service < Service
    def self.autocomplete(prompt)
      GPT3::Completion.create(prompt, gpt_3_settings)
        .fetch('choices', [])
        .map { |choice| choice.fetch('text') }
    end

    private
  
    def self.gpt_3_settings
      {
        n:           3,
        max_tokens:  128,
        temperature: 0.75,
        engine:      'curie'
      }
    end
  end
end
