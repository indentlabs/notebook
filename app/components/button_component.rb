# frozen_string_literal: true

class ButtonComponent < ViewComponent::Base
  def initialize(text:, left_icon:, right_icon:)
    @text       = text
    @left_icon  = left_icon
    @right_icon = right_icon
  end

end
