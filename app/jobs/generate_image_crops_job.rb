# Regenerates the banner / card / square derivatives of a gallery image
# after its framing changes (or when backfilling images uploaded before
# framing existed).
class GenerateImageCropsJob < ApplicationJob
  queue_as :default

  discard_on ActiveRecord::RecordNotFound

  def perform(record_type, record_id)
    record = record_type.constantize.find(record_id)
    ImageDerivativeService.generate!(record)
  end
end
