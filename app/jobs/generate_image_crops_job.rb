# Regenerates the banner / card / square derivatives of a gallery image
# after its framing changes (or when backfilling images uploaded before
# framing existed).
class GenerateImageCropsJob < ApplicationJob
  queue_as :default

  discard_on ActiveRecord::RecordNotFound

  # mode: 'crops' after a framing change; 'backfill' also produces the
  # xlarge WebP for images uploaded before it existed.
  def perform(record_type, record_id, mode = 'crops')
    record = record_type.constantize.find(record_id)
    if mode == 'backfill'
      ImageDerivativeService.backfill!(record)
    else
      ImageDerivativeService.generate!(record)
    end
  end
end
