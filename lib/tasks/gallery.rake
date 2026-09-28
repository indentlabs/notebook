namespace :gallery do
  desc "Generate the WebP shape derivatives (banner/card/square/social, plus xlarge) for uploads that don't have them yet (enqueues GenerateImageCropsJob)"
  task backfill_crops: :environment do
    scope = ImageUpload.where(crops_generated_at: nil).where.not(src_file_name: nil)
    count = 0

    scope.find_each do |image|
      GenerateImageCropsJob.perform_later('ImageUpload', image.id, 'backfill')
      count += 1
    end

    puts "Enqueued crop generation for #{count} image upload(s)."
  end

  desc "Record original pixel dimensions for uploads that were stored before width/height were captured"
  task backfill_dimensions: :environment do
    scope = ImageUpload.where(width: nil).where.not(src_file_name: nil)
    done = 0
    failed = 0

    scope.find_each do |image|
      begin
        geometry = Paperclip::Geometry.from_file(image.src.url(:original, timestamp: false))
        geometry.auto_orient
        image.update_columns(width: geometry.width.to_i, height: geometry.height.to_i)
        done += 1
      rescue StandardError => e
        failed += 1
        warn "ImageUpload #{image.id}: #{e.class}: #{e.message}"
      end
    end

    puts "Recorded dimensions for #{done} image(s); #{failed} failed."
  end

  desc "Record pixel dimensions for Basil images on pages, so their saved crops apply (run after the FixBasilBlobChecksums migration)"
  task backfill_basil_dimensions: :environment do
    scope = BasilCommission.where(width: nil).where.not(saved_at: nil).includes(image_attachment: :blob)
    done = 0
    failed = 0

    scope.find_each do |commission|
      next unless commission.image.attached?

      begin
        blob = commission.image.blob
        blob.analyze unless blob.metadata['width'].present?
        width, height = blob.metadata.values_at('width', 'height')
        raise "no dimensions after analysis" if width.blank? || height.blank?

        commission.update_columns(width: width, height: height)
        done += 1
      rescue StandardError => e
        failed += 1
        warn "BasilCommission #{commission.id}: #{e.class}: #{e.message}"
      end
    end

    puts "Recorded dimensions for #{done} Basil image(s); #{failed} failed."
  end
end
