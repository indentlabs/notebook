class ContentController < ApplicationController
  include HasOwnership

  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  # TODO: put a lot of this in ContentManagementService

  def index
    @content = content_type_from_controller(self.class)
               .where(user_id: current_user.id)
               .order(:name)

    @content = @content.where(universe: @universe_scope) if @universe_scope.present? && @content.build.respond_to?(:universe)
    @content ||= []

    begin
      @questioned_content = @content.sample
      questionable_params = content_param_list.reject { |x| x.is_a?(Hash) || x.to_s.end_with?('_id') }
      @question = QuestionService.question(Content.new @questioned_content.slice(*questionable_params))
    rescue
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @content }
    end
  end

  def show
    # TODO: Secure this with content class whitelist lel
    @content = content_type_from_controller(self.class).find(params[:id])

    # question = QuestionService.question(Content.new @content.slice(*content_param_list.flat_map { |v| v.is_a?(Symbol) ? v : v.keys.map { |k| k.to_s.chomp('_attributes').to_sym } }))
    begin
      questionable_params = content_param_list.reject { |x| x.is_a?(Hash) || x.to_s.end_with?('_id') }
      @question = QuestionService.question(Content.new @content.slice(*questionable_params))
    rescue
    end

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
    initialize_object

    if @content.save
      successful_response(@content, t(:create_success, model_name: humanized_model_name))
    else
      failed_response('new', :unprocessable_entity)
    end
  end

  def update
    content_type = content_type_from_controller(self.class)
    @content = content_type.find(params[:id])

    if @content.update_attributes(content_params)
      successful_response(@content, t(:update_success, model_name: humanized_model_name))
    else
      failed_response('edit', :unprocessable_entity)
    end
  end

  def destroy
    content_type = content_type_from_controller(self.class)
    @content = content_type.find(params[:id])
    @content.destroy

    url = send("#{@content.class.to_s.downcase.pluralize}_path")
    successful_response(url, t(:delete_success, model_name: humanized_model_name))
  end

  private

  def initialize_object
    content_type = content_type_from_controller(self.class)
    @content = content_type
               .new(content_params)
               .tap do |c|
      c.user_id = current_user.id
      c.universe = universe_from_params if c.respond_to? :universe # TODO: this doesn't actually work?
    end
  end

  # Override in content classes
  def content_params
    params
  end

  def universe_from_params
    return unless params[content_symbol].include? :universe
    Universe.where(user_id: current_user.id, name: params[content_symbol][:universe].strip).first
  end

  def content_symbol
    content_type_from_controller(self.class).to_s.downcase.to_sym
  end

  def successful_response(url, notice)
    respond_to do |format|
      format.html { redirect_to url, notice: notice }
      format.json { render json: @content || {}, status: :success, notice: notice }
    end
  end

  def failed_response(action, status)
    respond_to do |format|
      format.html { render action: action }
      format.json { render json: @content.errors, status: status }
    end
  end

  def humanized_model_name
    content_type_from_controller(self.class).model_name.human
  end
end
