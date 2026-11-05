# Password protection for worldbuilding pages. Routed on every page type, with the type coming from the
# route itself (see config/routes.rb), never from a parameter. Mirrors DocumentPasswordsController.
class PagePasswordsController < ApplicationController
  # The app-wide default quietly blanks the session when a token is bad, which would
  # drop the unlock and make a correct password look like it did nothing.
  protect_from_forgery with: :exception

  before_action :authenticate_user!, except: [:unlock]
  before_action :set_page
  before_action :verify_page_ownership, except: [:unlock]

  # Skip UI-heavy calls, since none of these actions render a page
  skip_before_action :cache_most_used_page_information
  skip_before_action :cache_forums_unread_counts

  rescue_from ActionController::InvalidAuthenticityToken do
    respond_to do |format|
      format.html { redirect_to back_to_page_path, flash: { page_password_error: 'Your session expired. Please try again.' } }
      format.json { render json: { error: 'Your session expired. Reload the page and try again.' }, status: :unprocessable_entity }
    end
  end

  # PATCH /plan/characters/1/password
  def update
    if @page.protect_with_password(params[:password])
      render_privacy
    else
      render json: { error: password_error }, status: :unprocessable_entity
    end
  end

  # DELETE /plan/characters/1/password
  def destroy
    new_privacy = params[:privacy]

    if HasPasswordProtection::PRIVACY_LABELS.keys.without('password').include?(new_privacy) && @page.remove_password_protection(new_privacy)
      render_privacy
    else
      render json: { error: "That page's privacy couldn't be changed." }, status: :unprocessable_entity
    end
  end

  # POST /plan/characters/1/unlock
  def unlock
    if !@page.password_protected?
      redirect_to back_to_page_path
    elsif @page.authenticate_page_password(params[:password].to_s)
      remember_page_unlock(@page)
      redirect_to back_to_page_path
    else
      redirect_to back_to_page_path, flash: { page_password_error: "That password isn't right. Please try again." }
    end
  end

  private

  # Just the part the owner can act on, since a blank password also fails the digest's own check
  def password_error
    message = @page.errors[:password].first
    message ? "Password #{message}" : @page.errors.full_messages.to_sentence
  end

  def render_privacy
    render json: { privacy: @page.privacy, label: @page.privacy_label, icon: @page.privacy_icon }
  end

  def page_class
    page_type = Rails.application.config.content_types[:all].find { |content_type| content_type.name == params[:page_type] }
    raise ActiveRecord::RecordNotFound unless page_type

    page_type
  end

  def set_page
    @page = page_class.find_by(id: params[:id])
    return if @page

    respond_to do |format|
      format.html { redirect_to root_path, notice: "Either that page doesn't exist or you don't have permission to view it!", status: :not_found }
      format.json { render json: { error: "That page doesn't exist." }, status: :not_found }
    end
  end

  # Only the page's owner manages its password, even though contributors can edit the page itself
  def verify_page_ownership
    return if PermissionService.user_owns_content?(user: current_user, content: @page)

    render json: { error: "Only this page's owner can change its password." }, status: :forbidden
  end

  # By id, since a bad token is caught before the page is looked up
  def back_to_page_path
    send("#{page_class.name.downcase}_path", params[:id])
  end
end
