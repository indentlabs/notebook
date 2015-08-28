# Controller for the Magic model
class MagicController < ApplicationController
  before_action :create_anonymous_account_if_not_logged_in,
                only: [:edit, :create, :update]

  before_action :require_ownership, only: [:edit, :update, :destroy]

  before_action :hide_private_magic, only: [:show]

  def index
    @magics = Magic.where(user_id: session[:user]).order(:name).presence || []

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @magics }
    end
  end

  def show
    @magic = Magic.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @magic }
    end
  end

  def new
    @magic = Magic.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @magic }
    end
  end

  def edit
    @magic = Magic.find(params[:id])
  end

  def create
    @magic = create_magic_from_params

    respond_to do |format|
      if @magic.save
        notice = t :create_success, model_name: Magic.model_name.human
        format.html { redirect_to @magic, notice: notice }
        format.json { render json: @magic, status: :created, location: @magic }
      else
        format.html { render action: 'new' }
        format.json { render json: @magic.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @magic = Magic.find(params[:id])

    respond_to do |format|
      if @magic.update_attributes(magic_params)
        notice = t :update_success, model_name: Magic.model_name.human
        format.html { redirect_to @magic, notice: notice }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @magic.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @magic = Magic.find(params[:id])
    @magic.destroy

    respond_to do |format|
      format.html { redirect_to magic_list_url }
      format.json { head :no_content }
    end
  end

  private

  def magic_params
    params.require(:magic).permit(
      :universe_id, :user_id,
      :name, :type_of,
      :manifestation, :symptoms,
      :element, :diety,
      :harmfulness, :helpfulness, :neutralness,
      :resource, :skill_level, :limitations,
      :notes, :private_notes)
  end

  def create_magic_from_params
    magic = Magic.new(magic_params)
    magic.user_id = session[:user]
    magic.universe = universe_from_magic_params
    magic
  end

  def universe_from_magic_params
    Universe.where(user_id: session[:user],
                   name: params[:magic][:universe].strip).first
  end
end
