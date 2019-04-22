Checklist to create a new content type:

- List all fields/types/relations out (for your sanity)
  - e.g. https://github.com/indentlabs/notebook/issues/258
  - name:string page_type:string user:references privacy:string deleted_at:datetime universe:references

- Generate models (with non-relation fields)
  - `rails g model Planet name:string user:references universe:references deleted_at:datetime privacy:string`
  - Edit the migration's page_type column to add a default value "Planet"
  - `rake db:migrate`

- Run `rake page_type:create` and type "Planet" at the prompt

- Edit app/models/content_types/planet.rb to define color and icon

- Add `has_many :planets` to universe.rb

- Add the content class to initializers/content_types.rb
  - most likely to :all, :available, and :free/:premium

- Find and add images to images/card-headers/
  - resize to 600x400 and optimize size to <100kb, ideally <50kb

- Customize groupings in config/attributes/planet.yml

- Add translations to en.yml
  - class name translations under activerecord.models
  - activerecord.attributes if you need a different label than humanized string
  - add questions for each field to serendipitous_questions
  - add line for each to content_oneliners
  - add content_descriptions (of relatively the same size)

- Give it a shot through the UI! :)
  - fill in each field to make sure all fields are working/permitted
  - make sure new/create and show/edit are working
  - check privacy toggling
