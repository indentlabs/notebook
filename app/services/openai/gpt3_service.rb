module Openai
  class Gpt3Service < Service
    def self.autocomplete
      require_andrew! # until we get approved by OpenAI

      completions = GPT3::Completion.create(prompt_params, gpt_3_settings)
        .fetch('choices', [])
        .map { |choice| choice.fetch('text') }
  
      render json: completions
    end
  end

  private

  def require_andrew!
    raise "Not allowed!" unless user_signed_in? && current_user.site_administrator?
  end

  def prompt_params
    params.require(:prompt)
  end

  def gpt_3_settings
    {
      n:           3,
      max_tokens:  128,
      temperature: 0.75
    }
  end
end
