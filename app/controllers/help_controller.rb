class HelpController < ApplicationController
  before_action :authenticate_user!

  before_action :set_sidenav_expansion

  layout 'tailwind'

  def index
    @page_title = "Help center"
  end
  
  def set_sidenav_expansion
    @sidenav_expansion = 'my account'
  end
end
