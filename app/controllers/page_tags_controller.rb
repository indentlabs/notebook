class PageTagsController < ApplicationController
  def remove
    # Params
    # {"page_type"=>"Location", "slug"=>"mountains", "controller"=>"page_tags", "action"=>"remove"
    return unless params.key?(:page_type) && params.key?(:slug)

    PageTag.where(
      page_type: params[:page_type],
      slug:      params[:slug],
      user_id:   current_user.id
    ).destroy_all

    return redirect_back fallback_location: root_path, notice: 'Tag deleted successfully.'
  end
end
