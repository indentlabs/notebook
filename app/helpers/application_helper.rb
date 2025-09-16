# Helps generate HTML constructs for object owned by the user
module ApplicationHelper
  def content_class_from_name(class_name)
    # If we pass in a class (e.g. Character instead of "Character") by mistake, just return it
    return class_name if class_name.is_a?(Class)

    # Extra whitelisting for some other classes we don't necessarily want in the content_types array
    return Folder if class_name == Folder.name

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
    
    # Sort with consistent criteria - using only position and creation date
    # This allows users to order images freely, including pinned images
    combined_images.sort_by do |img|
      # First by position - using presence check for nil/blank values
      position_value = if img[:data].respond_to?(:position) && img[:data].position.present?
                         img[:data].position 
                       else
                         999999
                       end
                       
      # Then by created date as secondary sort with fallback
      created_at = img[:created_at] || Time.current
      
      # Add a unique identifier to ensure stable sorting
      unique_id = "#{img[:type]}-#{img[:id]}"
      
      # Return sort keys array for stable sorting - no longer sorting by pinned status
      [position_value, created_at, unique_id]
    end
  end
  
  # Gets the best image to use for a preview (card/header) by prioritizing pinned images
  # @param regular_images [Array<ImageUpload>] regular image uploads
  # @param basil_images [Array<BasilCommission>] AI-generated images
  # @return [Hash] The best image to use as a preview (pinned if available)
  def get_preview_image(regular_images, basil_images)
    # First look for pinned images
    pinned_regular = regular_images.find { |img| img.respond_to?(:pinned?) && img.pinned? }
    pinned_basil = basil_images.find { |img| img.respond_to?(:pinned?) && img.pinned? }
    
    # Use the first pinned image found (prioritize regular uploads if both exist)
    if pinned_regular.present?
      return {
        id: pinned_regular.id,
        type: 'image_upload',
        data: pinned_regular,
        created_at: pinned_regular.created_at
      }
    elsif pinned_basil.present?
      return {
        id: pinned_basil.id,
        type: 'basil_commission',
        data: pinned_basil,
        created_at: pinned_basil.saved_at
      }
    end
    
    # If no pinned images, get all images
    combined = combine_and_sort_gallery_images(regular_images, basil_images)
    
    # Return the first sorted image, or nil if none available
    combined.first
  end

  def unread_inbox_count
    return 0 unless user_signed_in?
    
    @unread_inbox_count ||= begin
      Thredded::PrivateTopic
        .for_user(current_user)
        .unread(current_user)
        .count
    rescue
      0
    end
  end
end
