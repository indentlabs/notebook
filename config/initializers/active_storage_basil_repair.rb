# When a Basil image fails ActiveStorage's integrity check (its stored
# checksum doesn't match the file in S3), repair the checksum from the file
# and try once more, instead of failing the request with a 500. See
# BasilBlobRepair for why Basil checksums can be wrong. Blobs on other
# services are unaffected and still raise.
module RepairBasilChecksumOnOpen
  def open(tmpdir: nil, &block)
    super
  rescue ActiveStorage::IntegrityError
    raise if @basil_checksum_repair_attempted || !BasilBlobRepair.repairable?(self)

    @basil_checksum_repair_attempted = true
    raise unless BasilBlobRepair.repair!(self)

    # Downloader verifies the checksum before yielding, so the block hasn't
    # run yet and it's safe to run the whole thing again.
    open(tmpdir: tmpdir, &block)
  end
end

ActiveSupport.on_load(:active_storage_blob) do
  prepend RepairBasilChecksumOnOpen
end
