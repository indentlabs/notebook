# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password]

# Document bodies are sent in full on every autosave; logging them is slow for long documents
# and puts private writing in the logs.
Rails.application.config.filter_parameters += ['document.body']
