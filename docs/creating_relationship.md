# Example of adding a "leaders" relation to Group

## Create migration
- rails g model GroupLeadership user_id:integer group_id:integer leader_id:integer
- move model to models/content_groupers

## Migrate
rake db:migrate

## group.rb (containing model) changes
relates :leaders, with: :group_leaderships
+ add leaders to attribute_categories hash in config/attributes/group.yml

## content_groupers/group_leadership.rb
class GroupLeadership < ActiveRecord::Base
  belongs_to :user

  belongs_to :group
  belongs_to :leader, class_name: 'Character'
end

## Add attributes to whitelist in groups_controller.rb
+ group_leaderships_attributes:     [:id, :leader_id, :_destroy],

## Add any translations for the new fields to en.yml

## Hit Groups page in UI to make sure everything works! (Submit form, too)

--

# New approach (todo soon) so users can add their own
# - will also support linking to different content types!

using ContentRelationship model
- user_id
- relation_text:string            # Leaders
- linking_content_type:string     # Location
- linking_content_id:integer      # 5
- linked_content_type:string      # Character
- linked_content_id:integer       # 42
