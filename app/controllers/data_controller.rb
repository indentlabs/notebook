class DataController < ApplicationController
  before_action :set_sidenav_expansion

  def index
  end

  def recyclebin
  end

  private

  def set_sidenav_expansion
    @sidenav_expansion = 'my account'
  end
end
