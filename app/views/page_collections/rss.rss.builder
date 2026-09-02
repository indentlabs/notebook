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
    xml.webMaster "hello@notebook.ai (Notebook.ai)"
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
        # Feed readers get the legacy JPEG/PNG size rather than WebP
        cover = submission.content.respond_to?(:cover_image) ? submission.content.cover_image : nil
        enclosure_url = cover && (cover.url(:hero) || cover.original_url)
        if enclosure_url.present?
          begin
            enclosure_url = URI.join(request.base_url, enclosure_url).to_s unless enclosure_url.start_with?('http')
            xml.enclosure url: enclosure_url, type: enclosure_url.split('?').first.end_with?('.png') ? 'image/png' : 'image/jpeg'
          rescue => e
            # Skip if image URL generation fails
            Rails.logger.warn "RSS image enclosure failed: #{e.message}"
          end
        end
      end
    end
  end
end