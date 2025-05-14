require 'net/http'
require 'uri'
require 'json'
require 'base64'
require 'tempfile'
require 'aws-sdk-s3'

class GenerateBasilImageJob < ApplicationJob
  queue_as :default

  # Define potential errors for rescue
  class ApiError < StandardError; end

  def perform(basil_commission_id)
    # Find the BasilCommission record
    commission = BasilCommission.find(basil_commission_id)

    # Skip if already completed (image attached)
    return if commission.image.attached?

    # Details we can use:
    # commission.prompt - the prompt for the image
    # commission.style - the style of the image
    # commission.entity_type - the type of entity the image is for (e.g. Character, Location, etc)
    prompt_to_send = "(#{commission.style} style), #{commission.entity_type}, #{commission.prompt}"

    # Make the API request to generate the image
    endpoint_url = ENV.fetch("BASIL_ENDPOINT")
    api_url = URI.join(endpoint_url, '/sdapi/v1/txt2img')

    puts "*" * 100
    puts "Prompt: #{prompt_to_send}"
    puts "*" * 100

    payload = {
      prompt: prompt_to_send,
      steps: 20,
      # Add other parameters like negative_prompt, width, height, sampler_index, etc. as needed
      # Example:
      negative_prompt: "(naked, nudity, nsfw, nude), (sex, hardcore, porn, pornographic), xxx, low quality, blurry, worst quality, diptych, triptych, multiple images, multiple subjects, signed, signature, watermark, watermarked",
      width: 512,
      height: 512,
      override_settings: {
        sd_model_checkpoint: (commission.style == "anime") ? "openxl" : "photorealism.safetensors",
      },
      sampler_index: "DPM++ 3M SDE",
      cfg_scale: 4
    }.to_json

    begin
      response = Net::HTTP.post(api_url, payload, "Content-Type" => "application/json")
      response.value # Raises an HTTPError if the response is not 2xx

      response_data = JSON.parse(response.body)
      image_data_base64 = response_data['images']&.first

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