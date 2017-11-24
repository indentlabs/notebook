class UniversesController < ContentController

  # TODO: pull list of content types out from some centralized list somewhere
  [
    :characters, :locations, :items, :creatures, :races, :religions, :groups, :magics, :languages, :floras, :scenes
  ].each do |content_type_name|
    define_method content_type_name do
      @content_type = content_type_name.to_s.singularize.capitalize.constantize

      @universe = Universe.find(params[:id])
      @content_list = @universe.send(content_type_name).is_public.order(:name)

      render :content_list
    end
  end

  private

  def content_params
    params.require(:universe).permit(content_param_list)
  end

  def content_param_list
    [
      :user_id,
      :name, :description, :genre,
      :laws_of_physics, :magic_system, :technologies,
      :history,
      :privacy,
      :notes, :private_notes,
      custom_attribute_values: [:name, :value],
    ]
  end
end
