# Helps to get content owned by the current user
module MyContentHelper
  %w(characters universes items languages locations).each do |content_type|
    define_method "my_#{content_type}" do
      content_type.singularize.titleize.constantize.where(user_id: session[:user])
    end
  end
end
