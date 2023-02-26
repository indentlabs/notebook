class BasilController < ApplicationController
  before_action :authenticate_user!, except: [:complete_commission]

  before_action :require_admin_access, only: [:review], unless: -> { Rails.env.development? }

  def index
    @characters = @current_user_content['Character']
  end

  def character
    @character = current_user.characters.find(params[:id])

    category_ids = AttributeCategory.where(
      user_id: current_user.id,
      entity_type: 'character',
      label: ['Looks', 'Appearance']
    ).pluck(:id)
    @appearance_fields = AttributeField.where(attribute_category_id: category_ids)
    @attributes = Attribute.where(
      attribute_field_id: @appearance_fields.pluck(:id), 
      entity_id: @character.id, 
      entity_type: 'Character'
    )

    gender_field = @character.overview_field('Gender')
    @gender_value = Attribute.find_by(attribute_field_id: gender_field.id, entity: @character).try(:value)

    age_field = @character.overview_field('Age')
    @age_value = Attribute.find_by(attribute_field_id: age_field.id, entity: @character).try(:value)

    @commissions = BasilCommission.where(entity_type: 'Character', entity_id: @character.id).order('id DESC')
    @can_request_another = @commissions.all? { |c| c.complete? }
  end

  def info
    # total commissions
    # queue size (total commissions - completed commissions)
    # average time to complete today / this week
    # commissions per day bar chart
    # count(average time to complete) bar chart
  end

  def review
    @recent_commissions = BasilCommission.all.includes(:entity, :user).order('id DESC').limit(500)
  end

  def commission_character
    @character = current_user.characters.find(params[:id])

    # Build the prompt
    category_ids = AttributeCategory.where(
      user_id: current_user.id, entity_type: 'character', label: ['Looks', 'Appearance']
    ).pluck(:id)
    appearance_fields = AttributeField.where(attribute_category_id: category_ids)
    attributes = Attribute.where(
      attribute_field_id: appearance_fields.pluck(:id), 
      entity_id: @character.id, 
      entity_type: 'Character'
    )

    gender_field = @character.overview_field('Gender')
    gender_value = Attribute.find_by(attribute_field_id: gender_field.id, entity: @character).try(:value)

    age_field = @character.overview_field('Age')
    age_value = Attribute.find_by(attribute_field_id: age_field.id, entity: @character).try(:value)

    if age_value.present? && age_value.to_i.to_s == age_value
      age_value = "#{age_value} years old"
    end

    formatted_field_values = appearance_fields.map do |field|
      value = attributes.detect { |a| a.attribute_field_id == field.id }.try(:value)
      next if value.nil? || value.blank? || ['none', 'n/a', 'no', '.', '-', ' '].include?(value.try(:downcase))

      "#{field.label}: #{value.gsub(',', '')}"
    end
    prompt = [
      gender_value,
      age_value,
      formatted_field_values.compact.join(', '),
    ].compact.join(', ')

    BasilCommission.create!(
      user:        current_user,
      entity_type: 'Character',
      entity_id:   @character.id,
      prompt:      prompt,
      style:       params.fetch('style', 'realistic'),
      job_id:      SecureRandom.uuid
    )

    redirect_to basil_character_path(@character)
  end

  def complete_commission
    commission = BasilCommission.find_by(job_id: params[:jobid])
    commission.update(completed_at: DateTime.current)

    # TODO: we should attach the S3 object to the commission.image attachment
    # but I dunno how to do that yet. See broken attempts below.

    # s3 = Aws::S3::Resource.new(region: "us-east-1")
    # obj = s3.bucket("basil-characters").object("job-#{params[:jobid]}.png")
    # blob_params = {
    #   filename: File.basename(obj.key), 
    #   content_type: obj.content_type, 
    #   byte_size: obj.size, 
    #   checksum: obj.etag.gsub('"',"")
    # }
    # raise "wow"
    # blob = ActiveStorage::Blob.create_before_direct_upload!(**blob_params)

    # # By default, the blob's key (S3 key, in this case) a secure (random) token
    # # However, since the file is already on S3, we need to change the 
    # # key to match our file on S3
    # blob.update_attribute :key, obj.key

    # raise params.inspect

    render json: { success: true }
  end
end
