class EquipmentController < ApplicationController
  before_filter :create_anonymous_account_if_not_logged_in, :only => [:edit, :create, :update]
  before_filter :require_ownership_of_equipment, :only => [:update, :edit, :destroy]
  before_filter :hide_private_equipment, :only => [:show]

  def index
  	@equipment = Equipment.where(user_id: session[:user])
    
    if @equipment.size == 0
      @equipment = []
    end
    
		@equipment = @equipment.sort { |a, b| a.name.downcase <=> b.name.downcase }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @equipment }
    end
  end

  def show
    @equipment = Equipment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @equipment }
    end
  end

  def new
    @equipment = Equipment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @equipment }
    end
  end

  def edit
    @equipment = Equipment.find(params[:id])
  end

  def create
    @equipment = Equipment.create(equipment_params)
    @equipment.user_id = session[:user]
    @equipment.universe = Universe.where(user_id: session[:user]).where(name: params[:equipment][:universe].strip).first

    respond_to do |format|
      if @equipment.save
        format.html { redirect_to @equipment, notice: 'Equipment was successfully created.' }
        format.json { render json: @equipment, status: :created, location: @equipment }
      else
        format.html { render action: "new" }
        format.json { render json: @equipment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @equipment = Equipment.find(params[:id])

    if params[:equipment][:universe].empty?
      params[:equipment][:universe] = nil
    else
      params[:equipment][:universe] = Universe.where(user_id: session[:user]).where(name: params[:equipment][:universe].strip).first
    end

    respond_to do |format|
      if @equipment.update_attributes(equipment_params)
        format.html { redirect_to @equipment, notice: 'Equipment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @equipment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @equipment = Equipment.find(params[:id])
    @equipment.destroy

    respond_to do |format|
      format.html { redirect_to equipment_list_url }
      format.json { head :no_content }
    end
  end
  
  private
    def equipment_params
      params.require(:equipment).permit(
        :universe_id, :user_id,
        :name, :equip_type,
        :description, :weight,
        :original_owner, :current_owner, :made_by, :materials, :year_made,
        :magic,
        :notes, :private_notes)
    end
end
