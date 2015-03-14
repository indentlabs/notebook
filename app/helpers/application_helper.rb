module ApplicationHelper

	# Will output a link to the item if it exists and is owned by the current logged-in user
	# Otherwise will just print a text title
	def link_if_present(name, type)
		if not session[:user]
			return name
		end

		result = nil
		type = type.downcase

		case type
		when "character"
			result = Character.where(:name => name, :user_id => session[:user])
		when "equipment"
			result = Equipment.where(:name => name, :user_id => session[:user])
		when "language"
			result = Language.where(:name => name, :user_id => session[:user])
		when "location"
			result = Location.where(:name => name, :user_id => session[:user])
		when "magic"
			result = Magic.where(:name => name, :user_id => session[:user])
		# Plot stuff
		when "universe"
			result = Universe.where(:name => name, :user_id => session[:user])
		end

		if result and result.length > 0
			return link_to name, result.first
		else
			return name
		end
	end

	def print_property(title, value, type = "")
		return unless value and value.length > 0

	  return [
	  	"<dt><strong>", title, ":</strong></dt>",
	  	"<dd>", simple_format(link_if_present(value, type)), "</dd>"
	  ].join("").to_s.html_safe
	end
end
