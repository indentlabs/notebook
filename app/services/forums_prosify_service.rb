class ForumsProsifyService < Service
  ENDLINE = "\r\n"

  def self.prosify_text(thredded_topic_id, strip_parentheticals=true)
    topic = Thredded::Topic.find_by(id: thredded_topic_id)
    prose = ""

    topic.posts.find_each do |post|
      paragraphs = post.content.split(ENDLINE)

      paragraphs.each do |paragraph|
        prose += "\t#{paragraph}#{ENDLINE}" unless strip_parentheticals && post.content.start_with?('(') && post.content.end_with?(')')
      end
    end

    prose
  end

  def self.prosify_html(thredded_topic_id, strip_parentheticals=true)
    topic = Thredded::Topic.find_by(id: thredded_topic_id)
    prose = ""

    user_display_name_cache = {}

    topic.posts.find_each do |post|
      user_display_name_cache[post.user_id] = post.user.try(:display_name) || "Anonymous user" unless user_display_name_cache.key?(post.user_id)

      tooltip = "authored by #{user_display_name_cache[post.user_id]}"
      prose += "<p class='tooltipped' data-tooltip='#{tooltip}' data-position='right'>#{post.content}</p>" unless strip_parentheticals && post.content.start_with?('(') && post.content.end_with?(')')
    end

    prose
  end

  def self.save_to_document(user, thredded_topic_id, strip_parentheticals=true)
    topic = Thredded::Topic.find_by(id: thredded_topic_id)

    user.documents.create!(
      title: "#{topic.title} (forums post)",
      body:  prosify_html(thredded_topic_id, strip_parentheticals)
    )
  end
end