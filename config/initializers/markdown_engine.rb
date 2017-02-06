# Markdown rendering singleton:
# https://github.com/vmg/redcarpet

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