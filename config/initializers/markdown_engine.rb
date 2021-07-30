# Markdown rendering singleton:
# https://github.com/vmg/redcarpet

# Is it worth keeping this in memory? It probably cuts down on a bit of page load time on requests that
# render markdown, but may or may not be a huge memory hit/leak. We should probably do a tradeoff analysis
# on keeping this in memory versus initializing during page loads that use it.

Rails.application.config.markdown = Redcarpet::Markdown.new(
  Redcarpet::Render::HTML.new(
    with_toc_data: true,
    safe_links_only: true,
    filter_html: true
  ),
  autolink: true,
  tables: true,
  strikethrough: true,
  superscript: true,
  underline: true,
  highlight: true,
  footnotes: true,
)