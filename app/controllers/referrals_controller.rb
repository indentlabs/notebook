class ReferralsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_navbar_color
  before_action :set_navbar_actions
  before_action :set_sidenav_expansion

  def index
  end

  def scoreboard
    @scoreboard_users = User.joins(:referrals)
      .group("users.id")
      .order("count(users.id) DESC")
      .limit(10)
      .includes(:referrals)
  end

  private

  def set_navbar_color
    # @navbar_color = '#9196F3'
  end

  def set_navbar_actions    
    @navbar_actions = [{
      label: "Your referrals",
      href:  main_app.referrals_path
    },
    {
      label: "Scoreboard",
      href:  main_app.scoreboard_path
    }]
  end

  def set_sidenav_expansion
    @sidenav_expansion = 'my account'
  end
end
