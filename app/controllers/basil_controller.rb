class BasilController < ApplicationController
  before_action :authenticate_user!, except: [:complete_commission]

  before_action :require_admin_access, only: [:review], unless: -> { Rails.env.development? }

  def index
    @characters = @current_user_content['Character']
  end

  def character
    @character  = current_user.characters.find(params[:id])
    @guidance   = BasilFieldGuidance.find_or_initialize_by(entity: @character, user: current_user).try(:guidance)
    @guidance ||= {}

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

    @gender_field = @character.overview_field('Gender')
    if @gender_field
      @gender_value = Attribute.find_by(attribute_field_id: @gender_field.id, entity: @character).try(:value)
    end

    @age_field = @character.overview_field('Age')
    if @age_field
      @age_value = Attribute.find_by(attribute_field_id: @age_field.id, entity: @character).try(:value)
    end

    @commissions = BasilCommission.where(entity_type: 'Character', entity_id: @character.id)
                                  .order('id DESC')
                                  .limit(20)
                                  .includes(:basil_feedbacks)
    @in_progress_commissions = BasilCommission.where(entity_type: 'Character', entity_id: @character.id, completed_at: nil)
    @can_request_another = @in_progress_commissions.count < 3
  end

  def about
  end

  def stats
    @commissions = BasilCommission.all

    @queued = BasilCommission.where(completed_at: nil)
    @completed = BasilCommission.where.not(completed_at: nil)

    @average_wait_time = @completed.where('completed_at > ?', 24.hours.ago)
                                   .average(:cached_seconds_taken)
    @seconds_over_time = @completed.where('completed_at > ?', 24.hours.ago)
                                   .group_by { |c| (c.cached_seconds_taken / 60).round }
                                   .map { |minutes, list| [minutes, list.count] }

    # Projected date, at our current rate, to reach 1,000,000 images
    commission_counts_per_day   = @commissions.group_by_day(:completed_at).values
    @average_commissions_per_day = commission_counts_per_day.sum(0.0) / commission_counts_per_day.count
    commissions_left            = 1_000_000 - @commissions.count
    @days_til_1_million_commissions = commissions_left / @average_commissions_per_day

    # Feedback today
    @feedback_today = BasilFeedback.where('updated_at > ?', 24.hours.ago)
                                   .order(:score_adjustment)
                                   .group(:score_adjustment)
                                   .count
    @emoji_counts_today = @feedback_today.map do |score, count|
      emoji = case score
        when -2 then "Very Bad :'("
        when -1 then "Bad :("
        when  0 then "Meh :|"
        when  1 then "Good :)"
        when  2 then "Very Good :D"
        when  3 then "Lovely! <3"
      end
      [emoji, count]
    end

    # Feedback all time
    @feedback_all_time = BasilFeedback.order(:score_adjustment)
                                      .group(:score_adjustment)
                                      .count
    days_since_start = (Date.current - BasilFeedback.minimum(:updated_at).to_date)
    days_since_start = 1 if days_since_start.zero? # no dividing by 0 lol

    @emoji_counts_all_time = @feedback_all_time.map do |score, count|
      emoji = case score
        when -2 then "Very Bad :'("
        when -1 then "Bad :("
        when  0 then "Meh :|"
        when  1 then "Good :)"
        when  2 then "Very Good :D"
        when  3 then "Lovely! <3"
      end

      [emoji, count / days_since_start]
    end

    # queue size (total commissions - completed commissions)
    # average time to complete today / this week
    # commissions per day bar chart
    # count(average time to complete) bar chart
  end

  def review
    @recent_commissions = BasilCommission.all.includes(:entity, :user).order('id DESC').limit(100)
  end

  def commission
    # TODO: when we support multiple page types, we'll want to grab params[:entity_type] and params[:entity_id]
    #       and constantize the former, then find the entity from the user's content
    @character = current_user.characters.find(params[:id])

    # Build the prompt from the character's attributes
    category_ids = AttributeCategory.where(user: current_user, entity_type: 'character', label: ['Looks', 'Appearance'])
                                    .pluck(:id)
    appearance_fields = AttributeField.where(attribute_category_id: category_ids)
    attributes = Attribute.where(attribute_field_id: appearance_fields.pluck(:id),
                                 entity_id: @character.id,
                                 entity_type: 'Character')

    prompt_components = []

    # Step 1. Gender
    gender_field = @character.overview_field('Gender')
    if gender_field
      gender_value = Attribute.find_by(attribute_field_id: gender_field.id, entity: @character).try(:value).try(:strip)
      if gender_value.present?
        gender_importance = params.dig(:field, gender_field.id.to_s)
        gender_importance = gender_importance.to_f if gender_importance.present?
        
        if gender_importance == 1
          # If the importance is exactly 1, we can omit the parentheses and save a few tokens, since the
          # default attention importance is 1.
          prompt_components.push gender_value
        elsif gender_importance != 0
          # We also want to skip adding gender to the prompt at all if the user marked it as completely unimportant (-1 + 1 = 0)
          prompt_components.push "(#{gender_value}:#{gender_importance})"
        end
      end
    end

    # Step 2. Age
    age_field = @character.overview_field('Age')
    if age_field
      age_value = Attribute.find_by(attribute_field_id: age_field.id, entity: @character).try(:value).try(:strip)

      if age_value.present?
        # If the user simply entered a number in for an age field, we want to help SD along by 
        # giving it some context. Otherwise, we'll just use the value as-is.
        if age_value.to_i.to_s == age_value
          age_value = "#{age_value} years old"
        end

        age_importance = params.dig(:field, age_field.id.to_s)
        age_importance = age_importance.to_f if age_importance.present?

        if age_importance == 1
          prompt_components.push age_value
        elsif age_importance != 0
          # We also want to skip adding gender to the prompt at all if the user marked it as completely unimportant (-1 + 1 = 0)
          prompt_components.push "(#{age_value}:#{age_importance})"
        end
      end
    end

    field_importance_multipliers = {
      'hair':       1.15,
      'hair color': 1.55,
      'hair style': 1.10,
      'skin tone':  1.05,
      'race':       1.10,
      'eye color':  1.05,
      'gender':     1.15
    }

    # Step 3. Do it all again for every other field, too
    formatted_field_values = appearance_fields.map do |field|
      value = attributes.detect { |a| a.attribute_field_id == field.id }.try(:value)

      # If there is no value to this field (or looks like it doesn't apply), skip it.
      next if value.nil? || value.blank? || ['none', 'n/a', '.', '-', ' ', '?', '??', '???'].include?(value.try(:downcase))

      # If the field is something implied like a "Human" answer on "Race", skip it.
      next if field.label.downcase == 'race' && value.downcase == 'human'

      # We also want to do a little sanitizing of our field value.
      # We'll remove periods, newlines, and carriage returns, since they can mess up the prompt.
      value = value.gsub('.', ' ').gsub("\r", "").gsub("\n", " ")
      # We also remove parentheses, since they can mess up the prompt attention groups.
      value = value.gsub('(', '').gsub(')', '')
      value = value.strip

      # Get the importance of this field and add 1 to get back to our SD version
      importance = params.dig(:field, field.id.to_s) || 1.0
      importance = importance.to_f * field_importance_multipliers.fetch(field.label.downcase.to_sym, 1.0)
      importance = importance.round(2)

      # Lastly, we also do a little sanitation on the label
      label = field.label.downcase
      label = '' if label == 'identifying marks'

      # If the importance is exactly 1, we can omit the parentheses and save a few tokens, since the
      # default attention importance is 1.
      if importance == 1
        "#{value.gsub(',', '').gsub("\r", "").gsub("\n", " ")} #{field.label}"
      elsif importance != 0
        # We also want to skip adding gender to the prompt at all if the user marked it as completely unimportant (-1 + 1 = 0)
        "(#{value.gsub(',', '').gsub("\r", "").gsub("\n", " ")} #{field.label}:#{importance})"
      else
        # For 0-importance fields, we'll compact them out of the list in a moment
        nil
      end
    end

    prompt_components.concat formatted_field_values.compact
    prompt = prompt_components.join(', ')

    # Save our field weights as the latest guidance also
    guidance = BasilFieldGuidance.find_or_initialize_by(
      entity: @character,
      user:   current_user
    )
    guidance.update(guidance: params[:field])

    BasilCommission.create!(
      user:        current_user,
      entity_type: 'Character',
      entity_id:   @character.id,
      prompt:      prompt,
      style:       params[:basil_commission][:style],
      job_id:      SecureRandom.uuid
    )

    redirect_to basil_character_path(@character)
  end

  def complete_commission
    commission = BasilCommission.find_by(job_id: params[:jobid])
    return if commission.nil?

    commission.update(completed_at:   DateTime.current,
                      final_settings: JSON.parse(params[:settings]))

    commission.cache_after_complete!

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

  def feedback
    commission = BasilCommission.find_by(job_id: params[:jobid])
    score_adjustment = params[:basil_feedback][:score_adjustment].to_i
    score_adjustment = score_adjustment.clamp(-2, 2)

    feedback = commission.basil_feedbacks.find_or_initialize_by(user: current_user)
    feedback.update!(score_adjustment: score_adjustment)
  end

  def help_rate
    # Commissions without feedback:
    @reviewed_commission_ids = BasilFeedback.where(user: current_user)
                                           .pluck(:basil_commission_id)
    @commissions = BasilCommission.where.not(id: @reviewed_commission_ids)
                                  .where.not(completed_at: nil)
                                  .where(user: current_user)
                                  .order(created_at: :desc)
                                  .limit(50)
                                  .includes(:entity)
                                  .shuffle
  end
end
