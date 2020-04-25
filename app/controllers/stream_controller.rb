class StreamController < ApplicationController
  before_action :set_navbar_actions
  before_action :set_navbar_color
  before_action :set_sidenav_expansion

  def index
    @feed = ContentPageShare.all.order('created_at DESC')
  end

  def community
  end

  def global
  end

  def set_navbar_color
    @navbar_color = '#CE93D8'
  end

  # For showing a specific piece of content
  def set_navbar_actions
    @navbar_actions = [
      {
        label: 'From Your Network',
        href: '#'
      },
      {
        label: 'Around the world',
        href: '#'
      }
    ]
  end

  def set_sidenav_expansion
    @sidenav_expansion = 'community'
  end
end
