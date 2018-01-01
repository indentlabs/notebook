Checklist to create a new content type:

- List all fields/types/relations out (for your sanity)
  - e.g. https://github.com/indentlabs/notebook/issues/258

- Generate models (with non-relation fields)
  - rails g model Character name:string
  - (can probably merge this with the below soon)
  - probably want to just put core attributes here eventually, after de-systemizing other fields
  - don't forget to add `privacy`, `notes`, `private_notes`, `user_id`, `universe_id`, `deleted_at`

- Move models from models/ to models/content_types/
- Add concerns to new models (mirror existing models)
  - Probably just want to move them all to a single concern that injects the others eventually
- Define `self.color`, `self.icon`, `self.content_name`

- Generate CharactersController controller (inheriting from ContentController)
  - define `content_params` and `content_param_list`
    - use fields from the original list for the latter

- Add routes for the new content type
  - `resources :characters` in /plan scope
  - `get :characters, on: :member` in :universes resource
  - csv routes under /export scope
  - user-center routes under users resource

- Add the content class to initializers/content_types.rb
  - most likely to :all, :available, and :free/:premium

- Add the `has_many` associations to `Universe`
- Add the `has_many` associations to the `HasContent` concern

- Find and add images to images/card-headers/
  - resize to 600x400 and optimize size to <100kb, ideally <50kb

- Add translations to en.yml
  - class name translations under activerecord.models
  - activerecord.attributes if you need a different label than humanized string
  - add questions for each field to serendipitous_questions
  - add line for each to content_oneliners
  - add content_descriptions (of relatively the same size)

- Add config/attributes/town.yml

- Add hooks to ExportController
  - Add links to export/index.html.erb
- Add links to `content` and `content_list` and `content_in_universe` and everything else in HasContent concern
  - this totally needs refactored

- Give it a shot through the UI! :)
  - fill in each field to make sure all fields are working/permitted
  - make sure new/create and show/edit are working
  - check privacy toggling
