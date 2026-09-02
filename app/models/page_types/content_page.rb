class ContentPage < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :user
  belongs_to :universe

  attr_accessor :favorite, :cached_word_count

  include Authority::Abilities
  self.authorizer_name = 'ContentPageAuthorizer'

  # Lists built by User#content are generic ContentPage rows (one union
  # query across every page table) rather than Character/Location/... records,
  # so they need the gallery looked up through page_type + id instead of the
  # polymorphic association. Everything else (cover_image, cover_image_url)
  # comes from HasImageUploads unchanged.
  include HasImageUploads

  def image_uploads
    return @preloaded_image_uploads if defined?(@preloaded_image_uploads) && @preloaded_image_uploads

    ImageUpload.where(content_type: page_type, content_id: id)
  end

  def basil_commissions
    return @preloaded_basil_commissions if defined?(@preloaded_basil_commissions) && @preloaded_basil_commissions

    BasilCommission.where(entity_type: page_type, entity_id: id)
  end

  # Called by ApplicationController#preload_cover_images with the rows already
  # fetched for a whole list, so cover_image needs no further queries.
  def preload_gallery(uploads, commissions)
    @preloaded_image_uploads     = Array(uploads)
    @preloaded_basil_commissions = Array(commissions)
    clear_cover_image_cache
  end

  def icon
    self.page_type.constantize.icon
  end

  def color
    self.page_type.constantize.color
  end

  def text_color
    self.page_type.constantize.text_color
  end

  def favorite?
    # Handle different formats that might come from SQL queries
    case favorite
    when true, 1, "1", "true"
      true
    when false, 0, "0", "false", nil
      false
    else
      !!favorite
    end
  end

  def view_path
    send("#{self.page_type.downcase}_path", self.id)
  end

  def edit_path
    send("edit_#{self.page_type.downcase}_path", self.id)
  end

  def self.polymorphic_content_fields
    [:id, :name, :favorite, :page_type, :user_id, :cached_word_count, :created_at, :updated_at, :deleted_at, :archived_at, :privacy]
  end
end
