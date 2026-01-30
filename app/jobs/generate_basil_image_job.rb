require 'net/http'
require 'uri'
require 'json'
require 'base64'
require 'tempfile'
require 'aws-sdk-s3'

class GenerateBasilImageJob < ApplicationJob
  queue_as :basil

  # Define potential errors for rescue
  class ApiError < StandardError; end

  def perform(basil_commission_id)
    # Find the BasilCommission record
    commission = BasilCommission.find(basil_commission_id)

    # Skip if already completed (image attached)
    return if commission.image.attached?

    # Filter out specific words from the prompt that we don't want to include in image generation
    sanitized_commmission_prompt = commission.prompt.gsub(/(nudity|nsfw|nude|xxx|porn|pornographic|naked|sex|blowjob|undressed|stripped|stripping|stripper|birthmark)/i, '')

    # Details we can use:
    # commission.prompt - the prompt for the image
    # commission.style - the style of the image
    # commission.entity_type - the type of entity the image is for (e.g. Character, Location, etc)
    prompt_to_send = "(#{commission.style} style), #{commission.entity_type}, #{sanitized_commmission_prompt}"

    # Make the API request to generate the image
    endpoint_url = ENV.fetch("BASIL_ENDPOINT")
    api_url = URI.parse("#{endpoint_url}/v1/image/generations")
    api_key = ENV.fetch("BASIL_API_KEY")

    payload = {
      client_id: commission.user_id.to_s,
      prompt: prompt_to_send,
      negative_prompt: "(naked, nudity, nsfw, nude), (tits, breasts, boobs), (sex, hardcore, porn, pornographic), xxx, low quality, blurry, worst quality, diptych, triptych, multiple images, multiple subjects, signed, signature, watermark, watermarked, words, text"
    }.to_json

    begin
      http = Net::HTTP.new(api_url.host, api_url.port)
      http.use_ssl = api_url.scheme == 'https'

      request = Net::HTTP::Post.new(api_url.path)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = "Bearer #{api_key}"
      request.body = payload

      response = http.request(request)
      response.value # Raises an HTTPError if the response is not 2xx

      response_data = JSON.parse(response.body)
      image_data_base64 = response_data['image']

      raise ApiError, "No image data found in API response" unless image_data_base64

      # Decode the base64 image data
      image_data_binary = Base64.decode64(image_data_base64)

      # --- Manual S3 Upload and ActiveStorage Blob Creation --- 
      begin
        s3_client = Aws::S3::Client.new(
          region:            ENV.fetch('AWS_REGION', 'us-east-1'),
          access_key_id:     ENV.fetch('AWS_ACCESS_KEY_ID'),
          secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
        )
        bucket_name = ENV.fetch('S3_BASIL_BUCKET_NAME', 'basil-commissions')
        s3_key      = "job-#{commission.job_id || SecureRandom.uuid}.png" # Use job_id for the key
        filename    = s3_key # Use the same for the filename

        # 1. Upload directly to S3
        Rails.logger.info "Uploading key '#{s3_key}' to bucket '#{bucket_name}'"
        upload_response = s3_client.put_object(
          bucket:       bucket_name,
          key:          s3_key,
          body:         image_data_binary,
          content_type: 'image/png'
          # acl: 'public-read' # Only if you wanted public files, which we don't
        )

        # 2. Create the ActiveStorage Blob record manually
        checksum = upload_response.etag.gsub('"','') # ETag comes with quotes
        byte_size = image_data_binary.size

        blob = ActiveStorage::Blob.create!(
          key:          s3_key,
          filename:     filename,
          content_type: 'image/png',
          byte_size:    byte_size,
          checksum:     checksum,
          service_name: :amazon_basil # Crucial: Specify the service!
        )

        # 3. Associate the blob with the commission
        # Note: We use update! which saves immediately. No separate save! needed.
        commission.update!(image: blob)

        # 4. Update completed_at timestamp
        commission.update!(completed_at: Time.current)

      rescue Aws::S3::Errors::ServiceError => e
        Rails.logger.error "Manual S3 Upload/Blob Creation Failed: #{e.class} - #{e.message}"
        # Re-raise to let the job runner handle retries/failure
        raise e
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Manual Blob Creation/Association Failed: #{e.class} - #{e.message}"
        # Re-raise
        raise e
      end

    rescue Net::HTTPError, Net::OpenTimeout, Net::ReadTimeout, ApiError, JSON::ParserError => e
      # Handle API errors, timeouts, or decoding issues
      # Log the error, potentially retry the job, or mark the commission as failed
      Rails.logger.error("Basil Image Generation Failed for commission #{commission.id}: #{e.message}")
      # Example: Mark as failed (requires adding a status field to BasilCommission)
      # commission.update(status: 'failed', error_message: e.message)
      # Or re-raise to let the job runner handle retries/failure
      raise e
    end
  end
end 