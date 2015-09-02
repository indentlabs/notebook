class ContentController < ApplicationController
  include HasOwnership

  before_action :create_anonymous_account_if_not_logged_in, only: [:edit, :create, :update]

  def index
    @content = content_type_from_controller(self.class)
      .where(user_id: session[:user])
      .order(:name)
      .presence || []

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @content }
    end
  end

  def show
    @content = content_type_from_controller(self.class)
      .find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @content }
    end
  end

  def new
    @content = content_type_from_controller(self.class)
    	.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @content }
    end
  end

  def edit
    @content = content_type_from_controller(self.class)
    	.find(params[:id])
  end

  def create
    content_type = content_type_from_controller(self.class)

    @content = content_type
      .new(content_params)
      .tap do |c|
        c.user_id = session[:user]
        c.universe = universe_from_params if c.respond_to? :universe #todo this doesn't actually work
      end

    respond_to do |format|
      if @content.save
        notice = t :create_success, model_name: content_type.model_name.human
        format.html { redirect_to @content, notice: notice }
        format.json { render json: @content, status: :created, location: @content }
      else
        format.html { render action: 'new' }
        format.json { render json: @content.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    content_type = content_type_from_controller(self.class)

    @content = content_type.find(params[:id])

    respond_to do |format|
      if @content.update_attributes(content_params)
        notice = t :update_success, model_name: content_type.model_name.human
        format.html { redirect_to @content, notice: notice }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @content.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    content_type = content_type_from_controller(self.class)
    @content = content_type.find(params[:id])
    @content.destroy

    respond_to do |format|
      notice = t :delete_success, model_name: content_type.model_name.human
      format.html { redirect_to send("#{@content.class.to_s.downcase}_list_path"), notice: notice }
      format.json { head :no_content }
    end
  end

  private

  # Override in content classes
  def content_params
    params
  end

  def universe_from_params
    return unless params[content_symbol].include? :universe
    Universe.where(user_id: session[:user], name: params[content_symbol][:universe].strip).first
  end

  def content_symbol
    content_type_from_controller(self.class).to_s.downcase.to_sym
  end
end
