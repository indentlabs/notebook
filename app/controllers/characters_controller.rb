class CharactersController < ContentController
  autocomplete :character, :name
end
