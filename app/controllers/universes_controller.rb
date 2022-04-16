class UniversesController < ContentController
  layout 'tailwind', only: [:hub]

  def hub

  end

  # TODO: pull list of content types out from some centralized list somewhere
  (Rails.application.config.content_types[:all_non_universe] + [Timeline]).each do |content_type|
    content_type_name = content_type.name.downcase.pluralize.to_sym
    define_method content_type_name do
      @content_type = content_type_name.to_s.singularize.capitalize.constantize

      @universe = Universe.find_by(id: params[:id])
      return redirect_to(root_path, notice: "That universe doesn't exist!") unless @universe.present?
      @content_list = @universe.send(content_type_name)

      # todo just use current_user.can_view?(@universe) and/or individual filtering
      unless user_signed_in? && (current_user == @universe.user || Contributor.exists?(user_id: current_user.id, universe_id: @universe.id))
        @content_list = @content_list.is_public
      end

      @content_list = @content_list.order(:name)

      render :content_list
    end
  end

  private

  def content_param_list
    [
      :user_id,
      :name, :description, :genre,
      :laws_of_physics, :magic_system, :technology,
      :history,
      :privacy,
      :notes, :private_notes,
      custom_attribute_values: [:name, :value],
    ]
  end
end
