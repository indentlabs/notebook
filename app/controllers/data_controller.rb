class DataController < ApplicationController
  before_action :authenticate_user!

  before_action :set_sidenav_expansion

  def index
  end

  def recyclebin
  end

  def archive
  end

  def usage
    @content = current_user.content
  end

  private

  def set_sidenav_expansion
    @sidenav_expansion = 'my account'
  end
end
