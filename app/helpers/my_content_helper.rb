module MyContentHelper
  def my_characters
    return Character.where(user_id: session[:user])
  end

  def my_universes
    return Universe.where(user_id: session[:user])
  end
  
  def my_equipment
    return Equipment.where(user_id: session[:user])
  end
  
  def my_languages
    return Language.where(user_id: session[:user])
  end
  
  def my_locations
    return Location.where(user_id: session[:user])
  end
end
