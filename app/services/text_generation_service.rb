require 'net/http'
require 'uri'
require 'json'

class TextGenerationService
  def initialize(messages:, client_id: nil)
    @messages = messages
    @client_id = client_id || "notebook-ai"
  end

  def call
    url_string = ENV.fetch('TEXT_GENERATION_API_URL', 'https://api.chromagolem.com/v1/chat/completions')
    api_key = ENV.fetch('TEXT_GENERATION_API_KEY', 'dummy-key-for-now')

    url = URI(url_string)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    
    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{api_key}"
    
    body = {
      client_id: @client_id,
      messages: @messages
    }

    request.body = body.to_json
    
    begin
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        parsed = JSON.parse(response.read_body)
        # Assuming typical OpenAI `/v1/chat/completions` response structure:
        # { "choices": [{ "message": { "content": "..." } }] }
        return { success: true, content: parsed.dig("choices", 0, "message", "content") }
      else
        return { success: false, error: "API returned #{response.code}: #{response.read_body}" }
      end
    rescue => e
      return { success: false, error: e.message }
    end
  end
end
