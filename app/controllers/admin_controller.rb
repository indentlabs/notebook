class AdminController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!

  def dashboard
  end

  def universes
  end

  def characters
  end

  def locations
  end

  def items
  end
end
