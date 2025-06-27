# Helps generate HTML constructs for object owned by the user
module ApplicationHelper
  def content_class_from_name(class_name)
    # If we pass in a class (e.g. Character instead of "Character") by mistake, just return it
    return class_name if class_name.is_a?(Class)

    Rails.application.config.content_types_by_name[class_name]
  end

  # Will output a link to the item if it exists and is owned by the
  # current logged-in user. Otherwise will just print a text title
  def link_if_present(name, type)
    return name unless session[:user]
    result = find_by_name_and_type name, type.downcase, current_user.id

    result.nil? ? name : link_to(name, result)
  end

  def find_by_name_and_type(name, type, userid)
    model = type.titleize.constantize unless type.blank?
    model.where(name: name, user_id: userid).first unless model.nil?
  end

  def print_property(title, value, type = '')
    return unless value.present?

    [
      '<dt><strong>', title, ':</strong></dt>',
      '<dd>', simple_format(link_if_present(value, type)), '</dd>'
    ].join('').to_s.html_safe
  end

  def title(*parts)
    content_for(:title) { (parts << 'Notebook').join(' - ') } unless parts.empty?
  end

  def clean_links(html)
    return '' if html.nil?

    html.gsub!(/\<a href=["'](.*?)["']\>(.*?)\<\/a\>/mi, '<a href="\1" rel="nofollow">\2</a>')
    html.html_safe
  end

  def show_notice?(id: nil)
    user_signed_in? && current_user.notice_dismissals.where(notice_id: id).none?
  end

  # Combines and sorts gallery images from both ImageUploads and BasilCommissions
  # for consistent display across all gallery views in the application.
  # @param regular_images [Array<ImageUpload>] regular image uploads
  # @param basil_images [Array<BasilCommission>] AI-generated images
  # @return [Array<Hash>] Combined and sorted array of image hashes
  def combine_and_sort_gallery_images(regular_images, basil_images)
    combined_images = []
    
    # Add regular images with consistent structure
    regular_images.each do |image|
      combined_images << {
        id: image.id,
        type: 'image_upload',  # Use consistent naming across all usages
        data: image,
        created_at: image.created_at
      }
    end
    
    # Add basil images with consistent structure
    basil_images.each do |commission|
      combined_images << {
        id: commission.id,
        type: 'basil_commission',  # Use consistent naming across all usages
        data: commission,
        created_at: commission.saved_at
      }
    end
    
    # Sort with consistent criteria
    combined_images.sort_by do |img|
      # First by pinned status - pin always takes precedence 
      pinned_sort = (img[:data].respond_to?(:pinned?) && img[:data].pinned?) ? 0 : 1
      
      # Then by position - using presence check for nil/blank values
      position_value = if img[:data].respond_to?(:position) && img[:data].position.present?
                         img[:data].position 
                       else
                         999999
                       end
                       
      # Finally by created date as tertiary sort with fallback
      created_at = img[:created_at] || Time.current
      
      # Add a unique identifier to ensure stable sorting
      unique_id = "#{img[:type]}-#{img[:id]}"
      
      # Return sort keys array for stable sorting
      [pinned_sort, position_value, created_at, unique_id]
    end
  end
end
