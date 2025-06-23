class StyleguideController < ApplicationController
  layout 'tailwind', only: 'tailwind'

  def tailwind
  end
end
