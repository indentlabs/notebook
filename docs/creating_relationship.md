# Example of adding a "leaders" relation to Group

## Create migration
rails g migration CreateGroupLeaderships user_id:integer group_id:integer leader_id:integer

## Migrate
rake db:migrate

## group.rb (containing model) changes
relates :leaders, with: :group_leaderships
+ add leaders to attribute_categories hash

## Create content_groupers/group_leadership.rb
class GroupLeadership < ActiveRecord::Base
  belongs_to :user

  belongs_to :group
  belongs_to :leader, class_name: 'Character'
end

## Add attributes to whitelist in groups_controller.rb
+ group_leaderships_attributes:     [:id, :leader_id, :_destroy],

## Add any translations for the new fields to en.yml

## Hit Groups page in UI to make sure everything works! (Submit form, too)