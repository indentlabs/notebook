# We need to monkeypatch this in because paperclip internally uses URI.escape, and
# Rails 3 drops URI.escape support in favor of CGI.escape. After we've migrated off
# paperclip (or paperclip stops sucking), we can remove this monkeypatch.

module URI
  def URI.escape(url)
    CGI.escape(url)
  end
end