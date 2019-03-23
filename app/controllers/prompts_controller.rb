class PromptsController < ApplicationController
  before_action do
    return redirect_to(new_user_session_path) unless user_signed_in?

    @sidenav_expansion = 'writing'
    @navbar_color = '#FF9800'

    @navbar_actions = [
      {
        label: "Notebook prompts",
        href: main_app.prompts_path
      },
      {
        label: "Image prompts",
        href: main_app.prompts_image_path
      },
      {
        label: "Peer prompts",
        href: '/forum/writing-prompts'
      }
    ]
  end

  def notebook
    # todo move from main#prompts
  end

  def image
    generate_image_prompt(params[:query])
  end

  def generate_image_prompt(query)
    unsplash_params = {
      collections: [4508371]
    }
    if query.present?
      unsplash_params[:query] = query.join(',')
    end

    # if params[:orientation].present?
    #   unsplash_params[:orientation] = params[:orientation]
    # end

    response = Unsplash::Photo.random(
      collections: [4508371],
      query:       query.join(',')
    )
    @image_prompt = {
      id:          response.id,
      description: response.description,
      url:         response.urls.regular,
      source:      response.links.html,
      user: {
        name:      response.user.name,
        username:  response.user.username,
        portfolio: response.user.portfolio_url
      },
      location: {
        title:   response.location.try(:title),
        country: response.location.try(:country)
      }
    }

  # rescue Unsplash::Error
  #   flash.alert = "Unfortunately, our image host is temporarily down. Please try back again later!"
  end

  private

  def image_prompt_query_params
    # TODO do we need strong params here?
  end
end
