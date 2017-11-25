class UsersController < ApplicationController
  def index
    redirect_to new_session_path(User)
  end

  def show
    @user = User.find(params[:id])

    @content = @user.public_content.select { |type, list| list.any? }
    @tabs = @content.keys
    @stream = ContentChangeEvent.where(user_id: @user.id).order('id desc').limit(50)

    Mixpanel::Tracker.new(Rails.application.config.mixpanel_token).track(@user.id, 'viewed profile', {
      'sharing any content': @user.public_content_count != 0
    }) if Rails.env.production?
  end

  [
    :characters, :locations, :items, :creatures, :races, :religions, :groups, :magics, :languages, :floras, :scenes
  ].each do |content_type_name|
    define_method content_type_name do
      @content_type = content_type_name.to_s.singularize.capitalize.constantize

      @user = User.find(params[:id])
      @content_list = @user.send(content_type_name).is_public.order(:name)

      render :content_list
    end
  end
end
