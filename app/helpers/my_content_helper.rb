module MyContentHelper
  def my_characters
    Character.where(user_id: session[:user])
  end

  def my_universes
    Universe.where(user_id: session[:user])
  end

  def my_equipment
    Equipment.where(user_id: session[:user])
  end

  def my_languages
    Language.where(user_id: session[:user])
  end

  def my_locations
    Location.where(user_id: session[:user])
  end
end
