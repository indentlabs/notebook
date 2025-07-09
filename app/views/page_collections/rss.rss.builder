xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0", "xmlns:atom": "http://www.w3.org/2005/Atom", "xmlns:content": "http://purl.org/rss/1.0/modules/content/" do
  xml.channel do
    xml.title @page_collection.title
    xml.description @page_collection.description.present? ? @page_collection.description : "Latest articles from #{@page_collection.title}"
    xml.link page_collection_url(@page_collection)
    xml.tag! "atom:link", href: rss_page_collection_url(@page_collection), rel: "self", type: "application/rss+xml"
    xml.language "en-us"
    xml.ttl 60
    xml.lastBuildDate @pages.first&.accepted_at&.rfc822 || Time.current.rfc822
    xml.generator "Notebook.ai Collections"
    xml.webMaster "noreply@notebook.ai (Notebook.ai)"
    xml.managingEditor "#{@page_collection.user.email} (#{@page_collection.user.display_name})"
    
    # Add collection image if available
    if @page_collection.header_image.attached?
      xml.image do
        xml.url url_for(@page_collection.header_image)
        xml.title @page_collection.title
        xml.link page_collection_url(@page_collection)
        xml.width 144
        xml.height 144
      end
    end

    @pages.each do |submission|
      xml.item do
        xml.title submission.cached_content_name
        xml.description do
          xml.cdata! render(partial: 'rss_item_description', locals: { submission: submission })
        end
        xml.link url_for(submission.content)
        xml.guid url_for(submission.content), isPermaLink: true
        xml.pubDate submission.accepted_at.rfc822
        xml.author "#{submission.user.email} (#{submission.user.display_name})"
        xml.category submission.content_type
        
        # Add submission explanation as content if present
        if submission.explanation.present?
          xml.tag! "content:encoded" do
            xml.cdata! render(partial: 'rss_item_content', locals: { submission: submission })
          end
        end
        
        # Add enclosure for article image if present
        if submission.content.respond_to?(:random_image_including_private) && submission.content.random_image_including_private.present?
          begin
            if submission.content.random_image_including_private.respond_to?(:attached?) && submission.content.random_image_including_private.attached?
              image_url = url_for(submission.content.random_image_including_private)
              xml.enclosure url: image_url, type: "image/jpeg"
            end
          rescue => e
            # Skip if image URL generation fails
            Rails.logger.warn "RSS image enclosure failed: #{e.message}"
          end
        end
      end
    end
  end
end