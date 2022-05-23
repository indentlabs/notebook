class PageTagsController < ApplicationController
  def update
    raise "placeholder"
  end

  def rename
    old_tag_name = params[:tag].to_s
    new_tag_name = params.dig(old_tag_name, :label)

    if new_tag_name.blank?
      new_tag_name = 'Untitled Tag'
    end

    new_slug = PageTagService.slug_for(new_tag_name)

    current_user.page_tags.where(tag: old_tag_name).update_all(
      tag:  new_tag_name,
      slug: new_slug
    )
  end

  # Remove a tag and all of its links to a page
  def remove
    # Params
    # {"page_type"=>"Location", "slug"=>"mountains", "controller"=>"page_tags", "action"=>"remove"
    return unless params.key?(:page_type) && params.key?(:slug)

    PageTag.where(
      page_type: params[:page_type],
      slug:      params[:slug],
      user_id:   current_user.id
    ).destroy_all

    return redirect_back fallback_location: root_path, notice: 'Tag(s) deleted successfully.'
  end

  # Destroy a specific tag by ID
  def destroy
    PageTag.find_by(id: params[:id], user_id: current_user.id).destroy!

    return redirect_back fallback_location: root_path, notice: 'Tag(s) deleted successfully.'
  end
end
