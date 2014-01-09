class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :nl2br
  
  helper_method :character_picker
  helper_method :equipment_picker
  helper_method :language_picker
  helper_method :location_picker
  helper_method :universe_picker
  
  helper_method :universe_filter
  
  # View Helpers
  def nl2br(string)
    #simple_format string
    string.gsub("\n\r","<br>").gsub("\r", "").gsub("\n", "<br />").html_safe
  end
  
  def character_picker
  	characters = Character.where(user_id: session[:user])
  	return if characters.length == 0
  
  	html = '<span class="btn-group input-append help-inline">'
  	html << '<button class="btn dropdown-toggle" data-toggle="dropdown">'
  	html << '<i class="icon-user"></i> '
  	html << '<span class="caret"></span>'
  	html << '</button>'
  	html << '<ul class="dropdown-menu dropdown-picker">'
  	characters.each do |i|
  		html << '<li><a href="#">' + i.name + '</a></li>'
  	end
  	html << '</ul>'
  	html << '</span>'

  	return html.html_safe
  end
  
  def equipment_picker
  	equipment = Equipment.where(user_id: session[:user])
  	return if equipment.length == 0
  
  	html = '<span class="btn-group input-append help-inline">'
  	html << '<button class="btn dropdown-toggle" data-toggle="dropdown">'
  	html << '<i class="icon-shopping-cart"></i> '
  	html << '<span class="caret"></span>'
  	html << '</button>'
  	html << '<ul class="dropdown-menu dropdown-picker">'
  	equipment.each do |i|
  		html << '<li><a href="#">' + i.name + '</a></li>'
  	end
  	html << '</ul>'
  	html << '</span>'

  	return html.html_safe
  end
  
  def language_picker
  	languages = Language.where(user_id: session[:user])
  	return if languages.length == 0
  
  	html = '<span class="btn-group input-append help-inline">'
  	html << '<button class="btn dropdown-toggle" data-toggle="dropdown">'
  	html << '<i class="icon-comment"></i> '
  	html << '<span class="caret"></span>'
  	html << '</button>'
  	html << '<ul class="dropdown-menu dropdown-picker" id="universe-selector">'
  	languages.each do |i|
  		html << '<li><a href="#">' + i.name + '</a></li>'
  	end
  	html << '</ul>'
  	html << '</span>'

  	return html.html_safe
  end
  
  def location_picker
  	locations = Location.where(user_id: session[:user])
  	return if locations.length == 0
  
  	html = '<span class="btn-group input-append help-inline">'
  	html << '<button class="btn dropdown-toggle" data-toggle="dropdown">'
  	html << '<i class="icon-map-marker"></i> '
  	html << '<span class="caret"></span>'
  	html << '</button>'
  	html << '<ul class="dropdown-menu dropdown-picker">'
  	locations.each do |i|
  		html << '<li><a href="#">' + i.name + '</a></li>'
  	end
  	html << '</ul>'
  	html << '</span>'

  	return html.html_safe
  end
  
  def universe_picker
  	universes = Universe.where(user_id: session[:user])
  	return if universes.length == 0
  
  	html = '<span class="btn-group input-append help-inline">'
  	html << '<button class="btn dropdown-toggle" data-toggle="dropdown">'
  	html << '<i class="icon-globe"></i> '
  	html << '<span class="caret"></span>'
  	html << '</button>'
  	html << '<ul class="dropdown-menu dropdown-picker">'
  	universes.each do |i|
  		html << '<li><a href="#">' + i.name + '</a></li>'
  	end
  	html << '</ul>'
  	html << '</span>'

  	return html.html_safe
  end
  
  def universe_filter
  	universes = Universe.where(user_id: session[:user])
  	return if universes.length == 0
  	
  	unless @selected_universe_filter
  	  @selected_universe_filter = 'All universes'
  	end
  
  	html = '<span class="btn-group input-append help-inline">'
  	html << '<button class="btn dropdown-toggle" data-toggle="dropdown">'
  	html << '<i class="icon-globe"></i> ' + @selected_universe_filter + ' '
  	html << '<span class="caret"></span>'
  	html << '</button>'
  	html << '<ul class="dropdown-menu dropdown-picker">'
		html << '<li><a href="/plan/characters">All universes</a></li>'
  	universes.each do |i|
  		html << '<li><a href="/plan/characters/from/' + i.name.strip + '">' + i.name + '</a></li>'
  	end
  	html << '</ul>'
  	html << '</span>'

  	return html.html_safe
  end
  
  # Authentication
  def is_logged_in?
    session[:user]
  end
  
  def redirect_if_not_logged_in
    unless is_logged_in?
      redirect_to signup_path, :notice => "You must be logged in to do that!"
    end
  end

  def create_anonymous_account_if_not_logged_in
    unless is_logged_in?
      id = rand(10000000).to_s + rand(10000000).to_s # lol
      @user = User.new(:name => 'Anonymous-' + id.to_s, :email => id.to_s + '@localhost', :password => id.to_s)

      if @user.save
        session[:user] = @user.id
        session[:anon_user] = true
      else
        create_anonymous_account_if_not_logged_in
      end
    end
  end
  
  def require_ownership_of_character
  	character = Character.find(params[:id])
  	unless session[:user] and session[:user] == character.user.id
  	  redirect_to character_list_path, :notice => "You don't have permission to do that!"
  	end
  end
  
  def require_ownership_of_equipment
  	equipment = Equipment.find(params[:id])
  	unless session[:user] and session[:user] == equipment.user.id
  	  redirect_to equipment_list_path, :notice => "You don't have permission to do that!"
  	end
  end
  
  def require_ownership_of_language
  	language = Language.find(params[:id])
  	unless session[:user] and session[:user] == language.user.id
  	  redirect_to language_list_path, :notice => "You don't have permission to do that!"
  	end
  end
  
  def require_ownership_of_location
  	location = Location.find(params[:id])
  	unless session[:user] and session[:user] == location.user.id
  	  redirect_to location_list_path, :notice => "You don't have permission to do that!"
  	end
  end
  
  def require_ownership_of_magic
  	magic = Magic.find(params[:id])
  	unless session[:user] and session[:user] == magic.user.id
  	  redirect_to magic_list_path, :notice => "You don't have permission to do that!"
  	end
  end
  
  def require_ownership_of_universe
  	universe = Universe.find(params[:id])
  	unless session[:user] and session[:user] == universe.user.id
  	  redirect_to universe_list_path, :notice => "You don't have permission to do that!"
  	end
  end

  def hide_private_universe
    universe = Universe.find(params[:id])
    unless (session[:user] and session[:user] == universe.user.id) or universe.privacy.downcase == 'public'
      redirect_to universe_list_path, :notice => "You don't have permission to view that!"
    end
  end

  def hide_private_character
    character = Character.find(params[:id])
    unless (session[:user] and session[:user] == character.user.id) or (character.universe and character.universe.privacy.downcase == 'public')
      redirect_to character_list_path, :notice => "You don't have permission to view that!"
    end
  end

  def hide_private_equipment
    equipment = Equipment.find(params[:id])
    unless (session[:user] and session[:user] == equipment.user.id) or (equipment.universe and equipment.universe.privacy.downcase == 'public')
      redirect_to equipment_list_path, :notice => "You don't have permission to view that!"
    end
  end

  def hide_private_language
    language = Language.find(params[:id])
    unless (session[:user] and session[:user] == language.user.id) or (language.universe and language.universe.privacy.downcase == 'public')
      redirect_to language_list_path, :notice => "You don't have permission to view that!"
    end
  end

  def hide_private_location
    location = Location.find(params[:id])
    unless (session[:user] and session[:user] == location.user.id) or (location.universe and location.universe.privacy.downcase == 'public')
      redirect_to location_list_path, :notice => "You don't have permission to view that!"
    end
  end

  def hide_private_magic
    magic = Magic.find(params[:id])
    unless (session[:user] and session[:user] == magic.user.id) or (magic.universe and magic.universe.privacy.downcase == 'public')
      redirect_to magic_list_path, :notice => "You don't have permission to view that!"
    end
  end




end
