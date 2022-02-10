class InformationController < ApplicationController
  layout 'tailwind'
  
  Rails.application.config.content_types[:all].each do |content_type|
    define_method(content_type.name.downcase.pluralize) do
      @content_type = content_type

      render :content_type
    end
  end
end
