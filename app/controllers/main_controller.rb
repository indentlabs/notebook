# Controller for top-level pages of the site that do not have
# an associated model
class MainController < ApplicationController
  def index
    redirect_to :dashboard if user_signed_in?
  end

  def comingsoon
  end

  def anoninfo
  end

  def attribution
  end

  def dashboard
  end
end
