class PageTagService < Service
  def self.slug_for(text)
    text.downcase.gsub(/[^0-9a-z ]/i, '').gsub(/ /, '-')
  end

  def self.suggested_tags_for(class_name)
    case class_name
    when Building.name
      ["School", "Business"]
    when Character.name
      ["Main character", "Side character", "Background character"]
    when Condition.name
      ["Disease", "Blessing", "Curse"]
    when Country.name
      ["Kingdom", "Country", "Region"]
    when Creature.name
      ["Domesticated", "Wild", "Humanoid"]
    when Deity.name
      ["Good", "Evil", "Neutral"]
    when Flora.name
      ["Floral", "Weed", "Tree", "Bush"]
    when Government.name
      ["Republic", "Democracy", "Monarchy", "Dictatorship"]
    when Group.name
      ["Good", "Evil", "Secret"]
    when Item.name
      ["Weapon", "Armor", "Artifact", "Relic"]
    when Job.name
      ["Military", "Government", "Private sector"]
    when Landmark.name
      ["Cave", "Mountain", "Temple", "Ruins"]
    when Language.name
      ["Modern", "Ancient"]
    when Location.name
      ["Town", "City", "River", "Mountains", "Desert"]
    when Magic.name
      ["Spell", "Ability", "Superpower"]
    when Planet.name
      ["Habitable", "Inhabitable"]
    when Race.name
      ["Race", "Species", "Humanoid"]
    when Religion.name
      ["Modern", "Ancient", "Monotheistic", "Polytheistic"]
    when Scene.name
      ["Atmospheric", "Exposition", "Transition"]
    when Technology.name
      ["Military", "Consumer", "Theoretical"]
    when Town.name
      ["Village", "Town", "City", "Metropolis"]
    when Tradition.name
      ["Holiday", "Practice"]
    when Universe.name
      ["Favorite"]
    when Vehicle.name
      ["Automobile", "Train", "Plane", "Spaceship"]
    else
      []
    end
  end
end
