class MagicController < ApplicationController
  before_filter :create_anonymous_account_if_not_logged_in, :only => [:new, :edit, :show, :create, :update, :destoy]
  before_filter :require_ownership_of_magic, :only => [:show, :edit, :destroy]

  def index
  	@magics = Magic.where(user_id: session[:user])
    
    if @magics.size == 0
      @magics = []
    end
    
		@magics = @magics.sort { |a, b| a.name.downcase <=> b.name.downcase }

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
    @magic = Magic.new(params[:magic])
    @magic.user_id = session[:user]

    respond_to do |format|
      if @magic.save
        format.html { redirect_to @magic, notice: 'Magic was successfully created.' }
        format.json { render json: @magic, status: :created, location: @magic }
      else
        format.html { render action: "new" }
        format.json { render json: @magic.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @magic = Magic.find(params[:id])

    respond_to do |format|
      if @magic.update_attributes(params[:magic])
        format.html { redirect_to @magic, notice: 'Magic was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
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
end
