# We don't want to use Paperclip forever, but we're adding the following interpolater
# to enable attaching images that are already in S3 (created by Basil) and we haven't
# migrated to ActiveStorage yet so... here we are.
# JK LOL THIS DOESN'T EVEN WORK SO FEEL FREE TO DELETE AT WILL
# Paperclip.interpolates :src_or_default do |attachment, style|
#   attachment.instance.src_path ||
#     attachment.interpolator.interpolate(":class/:attachment/:id_partition/:style/:filename", attachment, style)
# end