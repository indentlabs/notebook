class InformationController < ApplicationController
  Rails.application.config.content_types[:all].each do |content_type|
    define_method(content_type.name.downcase.pluralize) do
      @content_type = content_type

      render :content_type
    end
  end

  # Override for Timeline since it doesn't use the attributes system
  def timelines
    @content_type = Timeline
    render :timeline
  end
end
