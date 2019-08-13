# This is commented out because it's probably a super bad idea, compounded by
# the fact that it causes some weirdities in the authority gem. Since we probably
# don't want to use that gem much longer (it's like 3 years deprecated), I don't
# want to introduce any more tech debt building on top of it. 

# It might be a good idea to have individual authorizers per content type, but I
# can't imagine why it would be.

# Rails.application.config.content_types[:premium].each do |content_type|
#   authorizer_class_name = "#{content_type.name}ContentAuthorizer"
#   Object.const_set(authorizer_class_name, Class.new(ContentAuthorizer) do

#     # Store the content type name on the authorizer so we can look for promos
#     class_variable_set(:@@class_name, content_type.name)
    
#     def self.createable_by?(user)
#       return false if ENV.fetch('CONTENT_BLACKLIST', nil)&.split(',')&.include?(user.email)

#       [
#         PermissionService.billing_plan_allows_extended_content?(user: user),
#         PermissionService.user_can_collaborate_in_universe_that_allows_extended_content?(user: user),
#         PermissionService.user_has_active_promotion_for_this_content_type(user: user, content_type: class_variable_get(:@@class_name))
#       ].any?
#     end
#   end)
# end
