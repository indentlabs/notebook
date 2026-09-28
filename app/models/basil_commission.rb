class BasilCommission < ApplicationRecord
  acts_as_paranoid
  include Authority::Abilities
  include HasImageFraming
  include HasCoverRoles

  belongs_to :user, optional: true
  belongs_to :entity, polymorphic: true, optional: true

  # Add scopes for image ordering
  scope :pinned, -> { where(pinned: true) }
  scope :ordered, -> { order(:position) }

  has_one_attached :image,
    service: :amazon_basil,
    dependent: :destroy

  has_many :basil_feedbacks, dependent: :destroy

  after_create :submit_to_job_queue!
  def submit_to_job_queue!
    # # TODO clean this up and put it in a config
    # region     = 'us-east-1'
    # queue_name = 'basil-commissions'

    # # TODO clean this up and put it in a service
    # sts_client = Aws::STS::Client.new(region: region)
    # queue_url = 'https://sqs.' + region + '.amazonaws.com/' + sts_client.get_caller_identity.account + '/' + queue_name
    # sqs_client = Aws::SQS::Client.new(region: region)

    # message_body = {
    #   job_id:    job_id,
    #   prompt:    prompt,
    #   style:     style,
    #   page_type: entity_type
    # }.to_json

    # sqs_client.send_message(
    #   queue_url:    queue_url,
    #   message_body: message_body
    # )

     # Enqueue the background job to generate the image
     GenerateBasilImageJob.perform_later(self.id)
  end

  # Builds the ActiveStorage blob for a Basil PNG already stored in the Basil
  # bucket under +key+. Everything is derived from the image bytes: an S3
  # ETag is a hex MD5 (and not even that for multipart uploads), while
  # ActiveStorage needs a base64 MD5 and an image/* content type to build the
  # resized and cropped variants the gallery shows.
  #
  # The type and size are recorded as already identified and analysed, which
  # saves ActiveStorage two downloads from S3 (sniffing the type on attach,
  # then the background analysis).
  def self.create_png_blob!(key, data)
    width, height = png_dimensions(data)
    metadata = { identified: true }
    metadata.merge!(width: width, height: height, analyzed: true) if width

    ActiveStorage::Blob.create!(
      key:          key,
      filename:     key,
      content_type: 'image/png',
      metadata:     metadata,
      byte_size:    data.bytesize,
      checksum:     Digest::MD5.base64digest(data),
      service_name: :amazon_basil
    )
  end

  # Attaches the PNG stored in the Basil bucket under +key+ (for images that
  # were uploaded to S3 by something other than GenerateBasilImageJob).
  def attach_stored_png!(key)
    data = Aws::S3::Resource.new(region: ENV.fetch('AWS_REGION', 'us-east-1'))
                            .bucket(ENV.fetch('S3_BASIL_BUCKET_NAME', 'basil-commissions'))
                            .object(key).get.body.read
    width, height = self.class.png_dimensions(data)
    update!(image: self.class.create_png_blob!(key, data), width: width, height: height)
  end

  PNG_SIGNATURE = "\x89PNG\r\n\x1A\n".b

  # [width, height] read from a PNG's header, or nil for anything else.
  # Basil returns PNGs; knowing the size up front means crops apply without
  # waiting for ActiveStorage's background analysis.
  def self.png_dimensions(data)
    return nil unless data.to_s.b.start_with?(PNG_SIGNATURE) && data.bytesize >= 24

    data.b[16, 8].unpack('NN')
  end

  def cache_after_complete!
    update(cached_seconds_taken: self.completed_at - self.created_at)
  end

  def complete?
    image.attached?
  end

  # Pixel size of the generated image. Falls back to ActiveStorage's
  # analysis metadata for commissions created before the columns existed.
  def width
    self[:width] || (image.attached? ? image.metadata['width'] : nil)
  end

  def height
    self[:height] || (image.attached? ? image.metadata['height'] : nil)
  end

  # Use acts_as_list for ordering images
  acts_as_list scope: [:entity_type, :entity_id]

  # Note: Pin unpinning logic is handled in the controller to prevent database locking issues

  private
end
