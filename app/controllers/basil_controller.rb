class BasilController < ApplicationController
  before_action :authenticate_user!, except: [:complete_commission, :about, :stats, :jam, :queue_jam_job, :commission_info]

  before_action :require_admin_access, only: [:review], unless: -> { Rails.env.development? }

  def index
    disabled_content_types = [Universe]

    @enabled_content_types = BasilService::ENABLED_PAGE_TYPES

    @content_type = params[:content_type].try(:humanize) || 'Character'
    if @content_type.present?
      if !@enabled_content_types.include?(@content_type)
        return raise "Invalid content type: #{params[:content_type]}"
      end

      @content = @current_user_content.fetch(@content_type, []).sort_by(&:name)
    end

    @generated_images_count = current_user.basil_commissions.with_deleted.count
  end

  def content
    # Fetch the content page from our already-queried cache of current user content
    @content_type = params[:content_type].humanize
    @content      = @current_user_content[@content_type].detect do |page|
      page.id == params[:id].to_i
    end
    raise "No content found for #{params[:content_type]} with ID #{params[:id]} for user #{current_user.id}" if @content.nil?

    # Fetch any existing Basil configurations/guidance for this character
    @guidance   = BasilFieldGuidance.find_or_initialize_by(
      entity_type: @content.page_type,
      entity_id:   @content.id,
      user:        current_user
    ).try(:guidance)
    @guidance ||= {}

    # Fetch all the related fields for this content type and their values
    # and format them into an array of [field, value] pairs to pass to the view
    @relevant_fields = []
    
    # TODO: either move this to the default field template (metadata for each field) or to a BasilService
    case @content_type
    when 'Character'
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Gender')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Age')
      @relevant_fields.push *BasilService.include_all_fields_in_category(current_user, @content, ['Looks', 'Appearance'])

    when 'Location'
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Name')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Type')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Description')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Geography', 'Area')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Geography', 'Climate')

    when 'Item'
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Name')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Item Type')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Description')
      @relevant_fields.push *BasilService.include_all_fields_in_category(current_user, @content, ['Looks', 'Appearance'])
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Abilities', 'Magical effects')

    when 'Building'
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Name')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Type of building')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Description')
      @relevant_fields.push *BasilService.include_all_fields_in_category(current_user, @content, ['Design'])

    when 'Condition'
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Type of condition')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Description')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Effects', 'Symptoms')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Effects', 'Visual effects')

    when 'Continent'
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Description')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Geography', 'Area')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Geography', 'Shape')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Geography', 'Topography')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Geography', 'Bodies of water')

    when 'Country'
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Description')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Geography', 'Area')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Geography', 'Climate')

    when 'Creature'
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Type of creature')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Description')
      @relevant_fields.push *BasilService.include_all_fields_in_category(current_user, @content, ['Looks'])
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Traits', 'Method of attack')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Traits', 'Methods of defense')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Comparisons', 'Similar creatures')

    when 'Deity'
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Description')
      @relevant_fields.push *BasilService.include_all_fields_in_category(current_user, @content, ['Appearance'])
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Symbolism', 'Elements')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Symbolism', 'Symbols')

    when 'Flora'
      @relevant_fields.push *BasilService.include_all_fields_in_category(current_user, @content, ['Appearance'])
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Description')

    when 'Food'
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Type of food')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Recipe', 'Ingredients')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Recipe', 'Cooking method')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Recipe', 'Color')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Recipe', 'Size')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Eating', 'Serving')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Eating', 'Texture')

    when 'Government'
      # DISABLE UNTIL WE HAVE A VISION OF WHAT TO GENERATE
      # but yolo lets see what we get with the below
      @relevant_fields.push *BasilService.include_all_fields_in_category(current_user, @content, ['Structure'])

    when 'Group'
      # PROBABLY NEEDS TEXTUAL INVERSION ON MEMBERS

    when 'Job'
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Type of job')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Description')

    when 'Landmark'
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Type of landmark')
      @relevant_fields.push *BasilService.include_all_fields_in_category(current_user, @content, ['Appearance'])
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Description')

    when 'Language'
      # DISABLE UNTIL WE HAVE A VISION OF WHAT TO GENERATE

    when 'Lore'
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Type')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Content', 'Genre')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Content', 'Tone')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Culture', 'Time period')
      # TODO textual inversion of any linked pages
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'About', 'Subjects')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Description')

    when 'Magic'
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Name')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Type of magic')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Description')
      @relevant_fields.push *BasilService.include_all_fields_in_category(current_user, @content, ['Appearance'])

    when 'Planet'
      @relevant_fields.push *BasilService.include_all_fields_in_category(current_user, @content, ['Geography'])
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Astral', 'Moons')

    when 'Race'
      @relevant_fields.push *BasilService.include_all_fields_in_category(current_user, @content, ['Looks'])

    when 'Religion'
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Beliefs', 'Places of worship')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Beliefs', 'Worship services')

    when 'Scene'
      # TODO hold off until we can use textual inversion of members + action + location

    when 'School'
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Type of school')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Identity', 'Colors')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Description')

    when 'Sport'
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Description')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Setup', 'Play area')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Setup', 'Equipment')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Setup', 'Number of players')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Setup', 'Scoring')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Culture', 'Uniforms')

    when 'Technology'
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Description')
      @relevant_fields.push *BasilService.include_all_fields_in_category(current_user, @content, ['Appearance'])

    when 'Town'
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Description')
      @relevant_fields.push *BasilService.include_all_fields_in_category(current_user, @content, ['Layout'])

    when 'Tradition'
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Type of tradition')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Celebrations', 'Activities')
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Celebrations', 'Symbolism')

    when 'Vehicle'
      @relevant_fields.push BasilService.include_specific_field(current_user, @content, 'Overview', 'Type of vehicle')
      @relevant_fields.push *BasilService.include_all_fields_in_category(current_user, @content, ['Looks'])

    end
    @relevant_fields.compact!

    # Finally, cache some state we can reference in the view
    @commissions = BasilCommission.where(entity_type: @content.page_type, entity_id: @content.id)
                                  .where(saved_at: nil)
                                  .order('id DESC')
                                  .limit(10)
                                  .includes(:basil_feedbacks, :image_blob)
    @in_progress_commissions = @commissions.select { |c| c.completed_at.nil? }
    @generated_images_count  = current_user.basil_commissions.with_deleted.count

    @can_request_another     = current_user.on_premium_plan? || @generated_images_count < BasilService::FREE_IMAGE_LIMIT
    @can_request_another     = @can_request_another && @in_progress_commissions.count < BasilService::MAX_JOB_QUEUE_SIZE
  end

  def about
  end

  def jam
    @recent_commissions = BasilCommission.where(entity_id: nil).order('id DESC').limit(20)
    @total_count = BasilCommission.where(entity_id: nil).count
  end

  def queue_jam_job
    created_prompt = [
      jam_params[:age],
      jam_params[:gender],
      *jam_params[:features]
    ].compact.join(', ')

    # Create our commission, then redirect back to preview it
    BasilCommission.create!(
      user:   current_user,
      entity: nil,
      prompt: created_prompt,
      job_id: SecureRandom.uuid,
      style:  ["realistic"].sample,
      final_settings: jam_params
    )

    redirect_back(fallback_location: basil_jam_path, notice: "#{jam_params.fetch(:name, '').presence || 'Your character'} will be visualized shortly. Find them on this page!")
  end

  def commission_info
    @commission = BasilCommission.find_by(job_id: params[:jobid])
    raise "No BasilCommission with ID #{params[:jobid]}" if @commission.nil?

    render json: {
      image_url: @commission.image.url,
      user_id: @commission.user_id,
      prompt: @commission.prompt,
      job_id: @commission.job_id,
      created_at: @commission.created_at,
      updated_at: @commission.updated_at,
      completed_at: @commission.completed_at,
      style: @commission.style,
      final_settings: @commission.final_settings,
      cached_seconds_taken: @commission.cached_seconds_taken,
    }
  end

  def stats
    @commissions = BasilCommission.all.with_deleted

    @queued = BasilCommission.where(completed_at: nil)
    @completed = BasilCommission.where.not(completed_at: nil).with_deleted

    @average_wait_time = @completed.where('completed_at > ?', 24.hours.ago)
                                   .average(:cached_seconds_taken) || 0
    @seconds_over_time = @completed.where('completed_at > ?', 24.hours.ago)
                                   .group_by { |c| ((c.cached_seconds_taken || 0) / 60).round }
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
    total = @feedback_today.values.sum
    @emoji_counts_today = @feedback_today.map do |score, count|
      emoji = case score
        when -2 then "Very Bad :'("
        when -1 then "Bad :("
        when  0 then "Meh :|"
        when  1 then "Good :)"
        when  2 then "Very Good :D"
        when  3 then "Lovely! <3"
      end
      [emoji, (count / total.to_f * 100).round(1)]
    end

    # Feedback all time
    @feedback_before_today = BasilFeedback.where('updated_at < ?', 24.hours.ago)
                                      .order(:score_adjustment)
                                      .group(:score_adjustment)
                                      .count
    days_since_start = (Date.current - BasilFeedback.minimum(:updated_at).to_date)
    days_since_start = 1 if days_since_start.zero? # no dividing by 0 lol

    total = @feedback_before_today.values.sum
    @emoji_counts_all_time = @feedback_before_today.map do |score, count|
      emoji = case score
        when -2 then "Very Bad :'("
        when -1 then "Bad :("
        when  0 then "Meh :|"
        when  1 then "Good :)"
        when  2 then "Very Good :D"
        when  3 then "Lovely! <3"
      end

      [emoji, (count / total.to_f * 100).round(1)]
    end

    active_styles = [
      BasilService.enabled_styles_for('Character'),
      BasilService.enabled_styles_for('Location'),
      # Also include anything we specifically want to track for now :)
      'painting2', 'painting3', 'anime'
    ].flatten.compact.uniq

    @total_score_per_style = BasilCommission.with_deleted
                                            .where(style: active_styles)
                                            .joins(:basil_feedbacks)
                                            .group(:style)
                                            .sum(:score_adjustment)
                                            .map { |style, average| [style, average.round(1)] }
                                            .sort_by(&:second)
                                            .reverse
    @average_score_per_style = BasilCommission.with_deleted
                                              .where(style: active_styles)
                                              .joins(:basil_feedbacks)
                                              .group(:style)
                                              .average(:score_adjustment)
                                              .map { |style, average| [style, average.round(1)] }
                                              .sort_by(&:second)
                                              .reverse

    @average_score_per_page_type = BasilCommission.with_deleted
                                                  .where.not(completed_at: nil)
                                                  .joins(:basil_feedbacks)
                                                  .group(:entity_type)
                                                  .average(:score_adjustment)
                                                  .map { |k, v| [k, (v * 100).round(1)] }.to_h

    # queue size (total commissions - completed commissions)
    # average time to complete today / this week
    # commissions per day bar chart
    # count(average time to complete) bar chart
  end

  def page_stats
    @page_type = params[:page_type]
    # TODO verify page_type is valid

    @commissions = BasilCommission.where(entity_type: @page_type)

    # Feedback today
    @feedback_today = BasilFeedback.where('updated_at > ?', 24.hours.ago)
                                   .where(basil_commission_id: @commissions.pluck(:id))
                                   .order(:score_adjustment)
                                   .group(:score_adjustment)
                                   .count
    total = @feedback_today.values.sum
    @emoji_counts_today = @feedback_today.map do |score, count|
      emoji = case score
        when -2 then "Very Bad :'("
        when -1 then "Bad :("
        when  0 then "Meh :|"
        when  1 then "Good :)"
        when  2 then "Very Good :D"
        when  3 then "Lovely! <3"
      end
      [emoji, (count / total.to_f * 100).round(1)]
    end

    # Feedback all time
    @feedback_before_today = BasilFeedback.where('updated_at < ?', 24.hours.ago)
                                          .where(basil_commission_id: @commissions.pluck(:id))
                                          .order(:score_adjustment)
                                          .group(:score_adjustment)
                                          .count
    days_since_start = (Date.current - BasilFeedback.minimum(:updated_at).to_date)
    days_since_start = 1 if days_since_start.zero? # no dividing by 0 lol

    total = @feedback_before_today.values.sum
    @emoji_counts_all_time = @feedback_before_today.map do |score, count|
      emoji = case score
        when -2 then "Very Bad :'("
        when -1 then "Bad :("
        when  0 then "Meh :|"
        when  1 then "Good :)"
        when  2 then "Very Good :D"
        when  3 then "Lovely! <3"
      end

      [emoji, (count / total.to_f * 100).round(1)]
    end

    active_styles = [
      BasilService.enabled_styles_for(@page_type),
      BasilService.experimental_styles_for(@page_type),
    ].flatten.compact.uniq

    @total_score_per_style = @commissions.where(style: active_styles)
                                              .joins(:basil_feedbacks)
                                              .group(:style)
                                              .sum(:score_adjustment)
                                              .map { |style, average| [style, average.round(1)] }
                                              .sort_by(&:second)
                                              .reverse
    @average_score_per_style = @commissions.where(style: active_styles)
                                              .joins(:basil_feedbacks)
                                              .group(:style)
                                              .average(:score_adjustment)
                                              .map { |style, average| [style, average.round(1)] }
                                              .sort_by(&:second)
                                              .reverse

    @average_score_per_page_type = @commissions.where.not(completed_at: nil)
                                                  .joins(:basil_feedbacks)
                                                  .group(:entity_type)
                                                  .average(:score_adjustment)
                                                  .map { |k, v| [k, (v * 100).round(1)] }.to_h

    # # queue size (total commissions - completed commissions)
    # # average time to complete today / this week
    # # commissions per day bar chart
    # # count(average time to complete) bar chart
  end

  def review
    @recent_commissions = BasilCommission.all.includes(:entity, :user).order('id DESC').limit(100)

    @commissions_per_user_id = BasilCommission.with_deleted.where('created_at > ?', 48.hours.ago).group(:user_id).order('count_all DESC').limit(5).count
    @unique_users_generating_count = BasilCommission.with_deleted.where('created_at > ?', 48.hours.ago).group(:user_id).count

    @current_queue_items = BasilCommission.where(completed_at: nil).order('created_at ASC')
  end

  def commission
    @generated_images_count  = current_user.basil_commissions.with_deleted.count
    if !current_user.on_premium_plan? && @generated_images_count > BasilService::FREE_IMAGE_LIMIT
      redirect_back fallback_location: basil_path, notice: "You've reached your free image limit. Please upgrade to generate more images."
      return
    end

    # Fetch the related content
    @content = @current_user_content[commission_params.fetch(:entity_type)]
                  .find { |c| c.id == commission_params.fetch(:entity_id).to_i }
    return raise "Invalid content commission params" if @content.nil?

    current_queue_size = current_user.basil_commissions.where(completed_at: nil).where(entity: @content).count
    if current_queue_size >= BasilService::MAX_JOB_QUEUE_SIZE
      redirect_back fallback_location: basil_path, notice: "You can only have #{BasilService::MAX_JOB_QUEUE_SIZE} commissions per page in progress at a time. Please wait for one to complete before requesting another."
      return
    end

    # Before creating the prompt, do a little config to tweak things to work well :)
    labels_to_omit_label_text = [
      "Name",
      "Identifying Marks",
      "Type",
      "Description",
      "Body Type",
      "Item type",
      "Type of food"
    ].map(&:downcase)
    field_importance_multipliers = {
      'hair':        1.15,
      'hair color':  1.55,
      'hair style':  1.10,
      'skin tone':   1.05,
      'race':        1.10,
      'eye color':   1.05,
      'gender':      1.15,
      'description': 1.00,
      'item type':   1.55,
      'type':        1.15,
      'type of building':  1.25,
      'type of condition': 1.25,
      'type of food':      1.25,
      'type of landmark':  1.25,
      'type of magic':     1.25,
      'type of school':    1.25,
      'type of vehicle':   1.25,
      'type of creature':  1.25
    }
    label_value_pairs_to_skip_entirely = [
      ['race', 'human']
    ]
    value_suffix_for_numerical_fields = {
      'age': ' years old'
    }

    # Prepare our prompt components
    prompt_components = []
    commission_params.fetch(:field).each do |field_id, field_data|
      label      = field_data[:label].strip
      value      = field_data[:value].gsub(',',  '')
                                     .gsub("\r", '')
                                     .gsub('(',  '')
                                     .gsub(')',  '')
                                     .gsub("\n", ' ')
                                     .strip
      importance = field_data[:importance].to_f

      # Field skips
      next if label_value_pairs_to_skip_entirely.include?([label.downcase, value.downcase])

      # Do any per-field manipulations
      importance *= field_importance_multipliers[label.downcase.to_sym]      if field_importance_multipliers.key?(label.downcase.to_sym)
      value      += value_suffix_for_numerical_fields[label.downcase.to_sym] if value_suffix_for_numerical_fields.key?(label.downcase.to_sym)
      label       = ''                                                       if labels_to_omit_label_text.include?(label.downcase)

      # Finally, cut down on any unnecessary precision to save more tokens
      importance = importance.round(2)

      component_text = "#{value} #{label}".strip
      if importance == 1.0
        # If the importance is exactly 1, we can omit the parentheses and save a few tokens, since the
        # default attention importance is 1.
        prompt_components.push "#{component_text}"
      elsif importance != 0
        # If the importance isn't 1 (default) or 0 (not included), we want to specify it in the prompt.
        prompt_components.push "(#{component_text}:#{importance})"
      end
    end

    # Build a prompt for Basil from the component parts
    prompt = prompt_components.join(', ')

    # Save our field weights as the latest guidance also
    guidance = BasilFieldGuidance.find_or_initialize_by(entity_type: @content.page_type,
                                                        entity_id:   @content.id,
                                                        user:        current_user)
    guidance_data = commission_params.fetch(:field)
                                     .transform_values { |data| data[:importance].to_f }
                                     .to_h
    guidance.update(guidance: guidance_data)

    BasilCommission.create!(
      user:        current_user,
      entity_type: @content.page_type,
      entity_id:   @content.id,
      prompt:      prompt,
      style:       commission_params.fetch(:style, 'realistic'),
      job_id:      SecureRandom.uuid
    )

    redirect_to basil_content_path(@content.page_type, @content.id)
  end

  def complete_commission
    commission = BasilCommission.find_by(job_id: params[:jobid])
    raise "Tried to complete commission with invalid job ID #{params[:jobid]}" if commission.nil?
    
    merged_settings = commission.final_settings || {}
    commission.update!(completed_at:   DateTime.current,
                       final_settings: merged_settings.merge(JSON.parse(params.fetch(:settings, "{}"))))

    # Attach the image in S3 to our `image` ActiveStorage relation
    key    = "job-#{params[:jobid]}.png"
    s3     = Aws::S3::Resource.new(region: "us-east-1")
    obj    = s3.bucket("basil-commissions").object(key)
    params = { 
      filename:     obj.key, 
      content_type: obj.content_type, # binary/octet-stream but we want image/png
      byte_size:    obj.size, 
      checksum:     obj.etag.gsub('"',"")
    }
    blob = ActiveStorage::Blob.create_before_direct_upload!(**params)
    blob.key = key
    blob.service_name = :amazon_basil
    blob.save!

    commission.update(image: blob.signed_id)
    commission.cache_after_complete!

    render json: { success: true }
  end

  def feedback
    commission = BasilCommission.find_by(job_id: params[:jobid])
    score_adjustment = params[:basil_feedback][:score_adjustment].to_i
    score_adjustment = score_adjustment.clamp(-3, 3)

    feedback = commission.basil_feedbacks.find_or_initialize_by(user: current_user)
    feedback.update!(score_adjustment: score_adjustment)
  end

  def help_rate
    @reviewed_commission_count = BasilFeedback.where(user: current_user).where.not(score_adjustment: nil).count

    @reviewed_commission_ids = BasilFeedback.where(user: current_user)
    if params.key?(:rating)
      @reviewed_commission_ids = @reviewed_commission_ids.where(score_adjustment: params[:rating].to_i)

      @commissions = BasilCommission.where(id: @reviewed_commission_ids.pluck(:basil_commission_id))
        .where.not(completed_at: nil)
        .where(user: current_user)
        .order(created_at: :desc)
        .limit(50)
        .includes(:entity)
        .order(completed_at: :desc)
    else
      # Unreviewed commissions
      @reviewed_commission_ids = @reviewed_commission_ids.where(score_adjustment: nil)

      @commissions = BasilCommission.where.not(id: @reviewed_commission_ids)
        .where.not(completed_at: nil)
        .where(user: current_user)
        .order(created_at: :desc)
        .limit(50)
        .includes(:entity)
        .order(completed_at: :desc)
    end
  end

  def save
    @commission = BasilCommission.find_by(
      id:   params[:id],
      user: current_user
    )
    @commission.update(saved_at: DateTime.current)
    render json: { success: true }, status: 200
  end

  def delete
    @commission = BasilCommission.find_by(
      id:   params[:id],
      user: current_user
    )
    @commission.destroy!
    render json: { success: true }, status: 200
  end

  private

  def commission_params
    params.require(:basil_commission).permit(:style, :entity_type, :entity_id, field: {})
  end

  def jam_params
    params.require(:commission).permit(:name, :age, :gender, features: [])
  end
end
