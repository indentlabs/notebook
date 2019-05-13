RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.authorize_with do
    redirect_to main_app.root_path unless user_signed_in? && current_user.site_administrator?
  end

  config.included_models = [
    "User",
    "ApiKey",
    "BillingPlan",
    "ImageUpload",
    "Referral",
    "Document",
  ] + Rails.application.config.content_types[:all].map(&:name)
  # Todo whitelist the fields we want to show for each model
  # config.model 'User' do
  #   list do
  #     field :name
  #     field :created_at
  #   end
  # end
end
