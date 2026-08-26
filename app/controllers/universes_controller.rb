class UniversesController < ContentController
  def hub
    # If the user came from a local page that is NOT the multiverse hub itself, store it as the return_to target
    if request.referer.present?
      begin
        referer_uri = URI(request.referer)
        # Verify the referer is from our domain and isn't just the multiverse page reloaded
        if referer_uri.host == request.host && referer_uri.path != multiverse_path
          @return_to = request.referer
        end
      rescue URI::InvalidURIError
        # ignore invalid referers
      end
    end

    @universes = @current_user_content.fetch('Universe', []).sort_by(&:name)
  end

  # TODO: pull list of content types out from some centralized list somewhere
  (Rails.application.config.content_types[:all_non_universe] + [Timeline]).each do |content_type|
    content_type_name = content_type.name.downcase.pluralize.to_sym
    define_method content_type_name do
      @content_type = content_type_name.to_s.singularize.capitalize.constantize

      @universe = Universe.find_by(id: params[:id])
      return redirect_to(root_path, notice: "That universe doesn't exist!", status: :not_found) unless @universe.present?
      @content_list = @universe.send(content_type_name)

      # todo just use current_user.can_view?(@universe) and/or individual filtering
      unless user_signed_in? && (current_user == @universe.user || Contributor.exists?(user_id: current_user.id, universe_id: @universe.id))
        @content_list = @content_list.is_public
      end

      @content_list = @content_list.order(:name)

      # Preload gallery images so preview cards don't query per-page
      if @content_type.reflect_on_association(:image_uploads)
        @content_list = @content_list.includes(:image_uploads)
      end
      if @content_type.reflect_on_association(:basil_commissions)
        @content_list = @content_list.includes(basil_commissions: { image_attachment: :blob })
      end

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
