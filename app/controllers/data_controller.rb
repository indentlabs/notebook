class DataController < ApplicationController
  before_action :authenticate_user!

  before_action :set_sidenav_expansion
  before_action :set_navbar_color

  layout 'tailwind'

  def index
    @page_title = "My data vault"
  end

  def yearly_index
    @years = [*current_user.created_at.year..Date.current.year].reverse
  end

  def review_year
    @year = params[:year].to_i
    comparable_year = "Jan 1, #{@year}".to_date

    @created_content = {}
    @total_created_non_universe_content = 0
    @words_written = 0
    Rails.application.config.content_types[:all].each do |klass|
      @created_content[klass.name] = klass.where(user_id: current_user.id)
                                          .where('created_at > ?', comparable_year.beginning_of_year)
                                          .where('created_at < ?', comparable_year.end_of_year)
                                          .order('created_at ASC')

      @words_written += WordCountUpdate.where(
        entity_type: klass.name, 
        entity_id: @created_content[klass.name].map(&:id)
      ).sum(:word_count)

      if klass.name != 'Universe'
        @total_created_non_universe_content += @created_content[klass.name].count
      end
    end

    @created_content['Document'] = current_user.documents
                                               .where('created_at > ?', comparable_year.beginning_of_year)
                                               .where('created_at < ?', comparable_year.end_of_year)
                                               .order('created_at ASC')

    @words_written += @created_content['Document'].sum(:cached_word_count)

    earliest_page_date = DateTime.current
    @earliest_page = nil
    @created_content.each do |content_type, list|
      earliest = list.first
      next if earliest.nil?

      if earliest.created_at < earliest_page_date
        earliest_page_date = earliest.created_at
        @earliest_page = earliest
      end
    end

    @created_content['Thredded::Topic'] = Thredded::Topic
      .where(user_id: current_user)
      .where('created_at > ?', comparable_year.beginning_of_year)
      .where('created_at < ?', comparable_year.end_of_year)
      .order('created_at ASC')

    @created_content['Thredded::Post'] = Thredded::Post
      .where(user_id: current_user)
      .where('created_at > ?', comparable_year.beginning_of_year)
      .where('created_at < ?', comparable_year.end_of_year)
      .order('created_at ASC')

    @created_content['ContentPageShare'] = current_user.content_page_shares
      .where('created_at > ?', comparable_year.beginning_of_year)
      .where('created_at < ?', comparable_year.end_of_year)
      .order('created_at ASC')

    @created_content['ImageUpload'] = current_user.image_uploads
      .where('created_at > ?', comparable_year.beginning_of_year)
      .where('created_at < ?', comparable_year.end_of_year)
      .order('created_at ASC')

    @created_content['PageCollection'] = current_user.page_collections
      .where('created_at > ?', comparable_year.beginning_of_year)
      .where('created_at < ?', comparable_year.end_of_year)
      .order('created_at ASC')

    @created_content['PageCollectionSubmission'] = current_user.page_collection_submissions
      .where('created_at > ?', comparable_year.beginning_of_year)
      .where('created_at < ?', comparable_year.end_of_year)
      .order('created_at ASC')

    @published_collections = PageCollection.where(id: @created_content['PageCollectionSubmission'].pluck(:page_collection_id) - @created_content['PageCollection'].pluck(:id))
    @publish_rate = @created_content['PageCollectionSubmission'].select { |s| s.accepted_at.present? && !@created_content['PageCollection'].pluck(:id).include?(s.page_collection_id) }.count.to_f / @created_content['PageCollectionSubmission'].count
  end

  def archive
  end

  def documents
    @documents = current_user
      .documents
      .order('title ASC')
      .includes([:document_analysis])
    
    @revisions = DocumentRevision.where(document_id: @documents.pluck(:id))

    revision_counts = @revisions.pluck(:document_id)
    @revisions_per_document_data = @documents.pluck(:title, :id).map do |title, did|
      [title, revision_counts.count(did)]
    end.reject { |title, count| count.zero? }.sort_by { |title, count| -count }
  end

  def uploads
    # Calculate total size by iterating through uploads instead of using SQL sum
    # This avoids the "no such column: src_file_size" error
    total_size = 0
    current_user.image_uploads.each do |upload|
      total_size += upload.src_file_size if upload.src_file_size.present?
    end
    
    @used_kb      = total_size / 1000
    @remaining_kb = current_user.upload_bandwidth_kb.abs

    if current_user.upload_bandwidth_kb < 0
      @percent_used = 100
    else
      @percent_used = (@used_kb.to_f / (@used_kb + @remaining_kb) * 100).round(3)
    end
    
    # Preload content associations for better performance
    @uploads = current_user.image_uploads.includes(:content).order(created_at: :desc)
  end

  def usage
    @content = current_user.content
  end

  def achievements
    @content = current_user.content
  end

  def tags
    @tags = current_user.page_tags
  end

  def discussions
    @topics         = Thredded::Topic.where(user_id: current_user.id)
    @posts          = Thredded::Post.where(user_id: current_user.id)
    @private_topics = Thredded::PrivateTopic.where(user_id: current_user.id)
    @private_posts  = Thredded::PrivatePost.where(user_id: current_user.id)

    @threads_posted_to = Thredded::Topic.where(id: @posts.pluck(:postable_id) - @topics.pluck(:id))

    @followed_topics = current_user.thredded_topic_follows.includes(:topic)
  end

  def collaboration
    universe_ids             = current_user.universes.pluck(:id)
    @collaborators           = Contributor.where(universe_id: universe_ids).includes(:user, :universe)#.uniq { |c| c.user_id }
    @shared_universes        = current_user.universes.where(id: @collaborators.pluck(:universe_id))
    collaborating_ids        = Contributor.where(user_id: current_user.id).pluck(:universe_id)
    @collaborating_universes = Universe.where(id: collaborating_ids)
  end

  def referrals
    @referrals      = current_user.referrals.includes(:referree)
    @referral_count = @referrals.count
    @share_link     = "https://www.notebook.ai/?referral=#{current_user.referral_code.code}"
  end

  def green
  end

  private

  def set_sidenav_expansion
    @sidenav_expansion = 'my account'
  end

  def set_navbar_color
    @navbar_color = '#795548'
  end
end
