# TODO we can probably remove this. Need to figure out what we're using for uploads again.

Paperclip::Attachment.default_options[:url] = ':s3_domain_url'
