class BasilCommission < ApplicationRecord
  belongs_to :user
  belongs_to :entity, polymorphic: true

  has_one_attached :image, dependent: :destroy

  has_many :basil_feedbacks, dependent: :destroy

  after_create :submit_to_job_queue!
  def submit_to_job_queue!
    # TODO clean this up and put it in a config
    region     = 'us-east-1'
    queue_name = 'basil-characters'

    # TODO clean this up and put it in a service
    sts_client = Aws::STS::Client.new(region: region)
    queue_url = 'https://sqs.' + region + '.amazonaws.com/' + 
      sts_client.get_caller_identity.account + '/' + queue_name
    sqs_client = Aws::SQS::Client.new(region: region)

    message_body = {
      job_id: job_id,
      prompt: prompt,
      style:  style
    }.to_json

    sqs_client.send_message(
      queue_url:    queue_url,
      message_body: message_body
    )
  end

  def complete?
    # image.attached?

    completed_at.present?
  end
end
