# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile += %w( thredded.js )

# Include Rails helpers in the assets pipeline
# This might be helpful for including e.g. link_to in js components, but is commented out until needed
# Rails.application.config.assets.configure do |env|
#   env.context_class.class_eval do
#     include ActionView::Helpers
#     include Rails.application.routes.url_helpers
#   end
# end