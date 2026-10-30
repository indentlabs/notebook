class DocumentPasswordsController < ApplicationController
  # The app-wide default quietly blanks the session when a token is bad, which would
  # drop the unlock and make a correct password look like it did nothing.
  protect_from_forgery with: :exception

  before_action :authenticate_user!, except: [:unlock]
  before_action :set_document
  before_action :verify_document_ownership, except: [:unlock]

  # Skip UI-heavy calls, since none of these actions render a page
  skip_before_action :cache_most_used_page_information
  skip_before_action :cache_forums_unread_counts

  rescue_from ActionController::InvalidAuthenticityToken do
    respond_to do |format|
      format.html { redirect_to document_path(params[:id]), flash: { document_password_error: 'Your session expired. Please try again.' } }
      format.json { render json: { error: 'Your session expired. Reload the page and try again.' }, status: :unprocessable_entity }
    end
  end

  # PATCH /documents/1/password
  def update
    if @document.protect_with_password(params[:password])
      render_privacy
    else
      render json: { error: @document.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  # DELETE /documents/1/password
  def destroy
    new_privacy = params[:privacy]

    if Document::PRIVACY_LABELS.keys.without('password').include?(new_privacy) && @document.remove_password_protection(new_privacy)
      render_privacy
    else
      render json: { error: "That document's privacy couldn't be changed." }, status: :unprocessable_entity
    end
  end

  # POST /documents/1/unlock
  def unlock
    if !@document.password_protected?
      redirect_to document_path(@document)
    elsif @document.authenticate_document_password(params[:password].to_s)
      remember_document_unlock(@document)
      redirect_to document_path(@document)
    else
      redirect_to document_path(@document), flash: { document_password_error: "That password isn't right. Please try again." }
    end
  end

  private

  def render_privacy
    render json: { privacy: @document.privacy, label: @document.privacy_label, icon: @document.privacy_icon }
  end

  def set_document
    @document = Document.find_by(id: params[:id])
    return if @document

    redirect_to root_path, notice: "Either that document doesn't exist or you don't have permission to view it!", status: :not_found
  end

  def verify_document_ownership
    return if @document.updatable_by?(current_user)

    render json: { error: "You don't have permission to do that!" }, status: :forbidden
  end
end
