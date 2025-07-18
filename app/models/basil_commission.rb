class BasilCommission < ApplicationRecord
  acts_as_paranoid

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

  def cache_after_complete!
    update(cached_seconds_taken: self.completed_at - self.created_at)
  end

  def complete?
    image.attached?
  end

  # Use acts_as_list for ordering images
  acts_as_list scope: [:entity_type, :entity_id]

  # Note: Pin unpinning logic is handled in the controller to prevent database locking issues

  private
end
