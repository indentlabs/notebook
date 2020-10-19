class InformationController < ApplicationController
  
  Rails.application.config.content_types[:all].each do |content_type|
    define_method(content_type.name.downcase.pluralize) do
      @content_type = content_type
      @page_title = "Creating #{content_type.name.downcase.pluralize}"
      render :content_type
    end
  end
end
