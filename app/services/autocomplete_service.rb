class AutocompleteService < Service
  # todo clean this up with some metaprogramming
  # todo some polymorphism for the subclasses

  def self.for(content, field_name)
    case content
    when Character
      CharacterAutocompleteService.for(field_name)
    when Creature
      CreatureAutocompleteService.for(field_name)
    else
      []
    end
  end

  def self.autocompleteable?(klass, field_name)
    self.for(klass, field_name).any?
  end
end
