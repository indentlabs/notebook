Checklist to create a new content type:

- List all fields/types/relations out (for your sanity)
  - e.g. https://github.com/indentlabs/notebook/issues/258

- Generate models (with non-relation fields)
  - `rails g model Planet name:string user:references universe:references deleted_at:datetime archived_at:datetime privacy:string favorite:boolean`
  - Edit the migration to add a page_type column with default value Planet
  - `rake db:migrate`

- Run `rake page_type:create` and type "Planet" at the prompt

- Edit app/models/content_types/planet.rb to define color and icon

- Add `has_many :planets` to universe.rb

- Add the content class to initializers/content_types.rb
  - most likely to :all, :available, and :free/:premium

- Find and add images to images/card-headers/
  - resize to 600x400 and optimize size to <100kb, ideally <50kb

- Customize categories/fields in config/attributes/continent.yml

- Add links (for each link, do the following)
  - rails g model ContinentLandmark continent:references landmark:references user:references
  - relates :landmarks, with: :continent_landmarks
  - add optional: true on all belongs_to :user
- Move all link models into models/page_groupers
- Add relevant links to any existing pages
  - Adding ANY fields to .yml will automatically create those fields for all existing users
    (this seems like something we MIGHT want for links, but probably DON'T want for text fields, so be careful)
- Add link attributes to ContinentsController
- Plus the following, so custom fields work too:
    custom_attribute_values:           [:name, :value],

- Add translations to en.yml
  - class name translations under activerecord.models
  - activerecord.attributes if you need a different label than humanized string
  - add questions for each field to serendipitous_questions
  - add line for each to content_oneliners
  - add content_descriptions (of relatively the same size)

- Restart the server

- Give it a shot through the UI! :)
  - fill in each field to make sure all fields are working/permitted
  - make sure new/create and show/edit are working
  - check privacy toggling

- Add lookup indexes on the new table