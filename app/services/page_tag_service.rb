class PageTagService < Service
  def self.slug_for(text)
    text.downcase.gsub(/[^0-9a-z ]/i, '').gsub(/ /, '-')
  end

  def self.suggested_tags_for(class_name)
    case class_name
    when Building.name
      ["School", "Business", "Residential", "Religious", "Government", "Military", "Historical", "Abandoned", "Underground", "Magical", "Headquarters", "Landmark", "WIP", "Complete", "Stub",
       "Ancient", "Modern", "Futuristic", "Secret", "Well-known", "Mysterious", "Imposing", "Central to plot", "Background detail", "Needs expansion"]
    when Character.name
      ["Main character", "Side character", "Background character", "Villain", "Hero", "Mentor", "Love interest", "Ally", "Rival", "Family member", "Historical figure", "Child", "Elder", "WIP", "Complete", "Stub",
       "Protagonist", "Antagonist", "Supporting", "Main plot", "Subplot", "Origin story", "High priority", "Needs development", "Tragic", "Comedic"]
    when Condition.name
      ["Disease", "Blessing", "Curse", "Magical affliction", "Mental condition", "Physical disability", "Temporary", "Permanent", "Contagious", "Hereditary", "Supernatural", "Rare", "Common", "WIP", "Complete", "Stub",
       "Unknown", "Legendary", "Tragic", "Beneficial", "Plot device", "Background detail", "Mysterious", "Needs research", "Science based", "Mythology inspired"]
    when Country.name
      ["Kingdom", "Country", "Region", "Empire", "Republic", "City-state", "Colony", "Island nation", "Confederation", "Disputed territory", "Fallen kingdom", "Hidden realm", "Tribal lands", "WIP", "Complete", "Stub",
       "Ancient", "Modern", "Developing", "Major power", "Minor nation", "Well-known", "Isolated", "Political entity", "Cultural focus", "Based on history"]
    when Creature.name
      ["Domesticated", "Wild", "Humanoid", "Mythical", "Magical", "Predator", "Aquatic", "Flying", "Subterranean", "Extinct", "Intelligent", "Hybrid", "Shapeshifter", "WIP", "Complete", "Stub",
       "Common", "Rare", "Legendary", "Keystone species", "Background fauna", "Terrifying", "Majestic", "Cute", "Mythology inspired", "Needs illustration"]
    when Deity.name
      ["Good", "Evil", "Neutral", "Creator", "Destroyer", "Nature deity", "War deity", "Love deity", "Death deity", "Trickster", "Ancient", "Forgotten", "Patron", "WIP", "Complete", "Stub",
       "Worshipped", "Obscure", "Legendary", "Major deity", "Minor deity", "Metaphysical", "Mythology inspired", "Central to plot", "Cultural element", "Needs expansion"]
    when Flora.name
      ["Floral", "Weed", "Tree", "Bush", "Magical", "Medicinal", "Poisonous", "Edible", "Rare", "Cultivated", "Aquatic", "Carnivorous", "Luminescent", "Extinct", "WIP", "Complete", "Stub",
       "Common", "Legendary", "Plot device", "Background detail", "Physical world", "Needs illustration", "Science based", "Mysterious", "Prehistoric", "Modern"]
    when Government.name
      ["Republic", "Democracy", "Monarchy", "Dictatorship", "Oligarchy", "Theocracy", "Feudal", "Tribal", "Anarchy", "Colonial", "Magocracy", "Puppet state", "Technocracy", "Confederation", "WIP", "Complete", "Stub",
       "Stable", "Unstable", "Corrupt", "Benevolent", "Social structure", "Political entity", "Based on history", "Central to plot", "Background detail", "Needs expansion"]
    when Group.name
      ["Good", "Evil", "Secret", "Military", "Religious", "Political", "Criminal", "Mercenary", "Merchant", "Nomadic", "Resistance", "Magical", "Ancient", "WIP", "Complete", "Stub",
       "Well-known", "Obscure", "Powerful", "Minor", "Main plot", "Subplot", "Social structure", "Cultural element", "Needs development", "Based on history"]
    when Item.name
      ["Weapon", "Armor", "Artifact", "Relic", "Magical", "Cursed", "Legendary", "Tool", "Jewelry", "Clothing", "Consumable", "Book", "Technology", "Ritual object", "WIP", "Complete", "Stub",
       "Common", "Rare", "Unique", "Plot device", "MacGuffin", "Ancient", "Modern", "Futuristic", "Needs illustration", "Mythology inspired"]
    when Job.name
      ["Military", "Government", "Private sector", "Artisan", "Merchant", "Criminal", "Religious", "Magical", "Academic", "Entertainment", "Nomadic", "Seasonal", "Hereditary", "WIP", "Complete", "Stub",
       "Common", "Rare", "Prestigious", "Lowly", "Social structure", "Economic system", "Cultural element", "Based on history", "Background detail", "Needs expansion"]
    when Landmark.name
      ["Cave", "Mountain", "Temple", "Ruins", "Waterfall", "Forest", "Monument", "Battlefield", "Sacred site", "Natural wonder", "Magical location", "Bridge", "Graveyard", "Portal", "WIP", "Complete", "Stub",
       "Famous", "Hidden", "Ancient", "Modern", "Physical world", "Plot location", "Mysterious", "Majestic", "Needs illustration", "Based on geography"]
    when Language.name
      ["Modern", "Ancient", "Dead", "Sacred", "Trade", "Secret", "Regional", "Magical", "Written only", "Spoken only", "Pidgin", "Artificial", "WIP", "Complete", "Stub",
       "Common", "Rare", "Scholarly", "Cultural element", "Based on linguistics", "Needs development", "Conlang", "Background detail", "Low priority", "Needs examples"]
    when Location.name
      ["Town", "City", "River", "Mountains", "Desert", "Forest", "Ocean", "Lake", "Island", "Swamp", "Tundra", "Valley", "Plateau", "Jungle", "Wasteland", "WIP", "Complete", "Stub",
       "Inhabited", "Uninhabited", "Explored", "Unexplored", "Dangerous", "Safe", "Physical world", "Plot location", "Needs map", "Based on geography"]
    when Magic.name
      ["Spell", "Ability", "Superpower", "Ritual", "Enchantment", "Elemental", "Necromancy", "Divination", "Illusion", "Healing", "Summoning", "Forbidden", "Innate", "WIP", "Complete", "Stub",
       "Common", "Rare", "Legendary", "Powerful", "Weak", "Metaphysical", "System-defining", "Plot device", "High priority", "Needs rules"]
    when Planet.name
      ["Habitable", "Inhabitable", "Earth-like", "Gas giant", "Desert world", "Ocean world", "Ice world", "Jungle world", "Artificial", "Moon", "Dying", "Ancient", "WIP", "Complete", "Stub",
       "Explored", "Unexplored", "Homeworld", "Colony", "Physical world", "Science based", "Needs map", "Central setting", "Background detail", "Needs development"]
    when Race.name
      ["Race", "Species", "Humanoid", "Ancient", "Magical", "Hybrid", "Extinct", "Subterranean", "Aquatic", "Aerial", "Nomadic", "Tribal", "Technological", "WIP", "Complete", "Stub",
       "Common", "Rare", "Dominant", "Minority", "Cultural focus", "Social structure", "Needs illustration", "Main characters", "Background people", "High priority"]
    when Religion.name
      ["Modern", "Ancient", "Monotheistic", "Polytheistic", "State religion", "Cult", "Animistic", "Shamanic", "Ancestor worship", "Nature worship", "Mystical", "Heretical", "Secretive", "Widespread", "WIP", "Complete", "Stub",
       "Dominant", "Minority", "Cultural element", "Metaphysical", "Based on history", "Mythology inspired", "Plot relevant", "Background detail", "Needs expansion"]
    when Scene.name
      ["Atmospheric", "Exposition", "Transition", "Action", "Dialogue", "Flashback", "Dream sequence", "Climactic", "Introduction", "Resolution", "Worldbuilding", "Character development", "Plot twist", "WIP", "Complete", "Stub",
       "Main plot", "Subplot", "High tension", "Low tension", "Mysterious", "Romantic", "Tragic", "Comedic", "High priority", "Needs revision"]
    when Technology.name
      ["Military", "Consumer", "Theoretical", "Ancient", "Futuristic", "Magical", "Medical", "Transportation", "Communication", "Energy", "Forbidden", "Experimental", "Everyday", "WIP", "Complete", "Stub",
       "Common", "Rare", "Revolutionary", "Obsolete", "Science based", "Plot device", "Physical world", "Needs illustration", "Background detail", "High priority"]
    when Town.name
      ["Village", "Town", "City", "Metropolis", "Hamlet", "Outpost", "Port", "Mining settlement", "Trading hub", "Fortress", "Religious center", "Abandoned", "Hidden", "Capital", "WIP", "Complete", "Stub",
       "Prosperous", "Poor", "Ancient", "Modern", "Plot location", "Character hometown", "Cultural focus", "Needs map", "Based on history", "Background detail"]
    when Tradition.name
      ["Holiday", "Practice", "Festival", "Ceremony", "Ritual", "Coming of age", "Seasonal", "Religious", "Cultural", "Family", "Military", "Ancient", "WIP", "Complete", "Stub",
       "Common", "Rare", "Widespread", "Regional", "Cultural element", "Social structure", "Based on history", "Mythology inspired", "Background detail", "Needs expansion"]
    when Universe.name
      ["Favorite", "Science fiction", "Fantasy", "Historical", "Post-apocalyptic", "Dystopian", "Utopian", "Alternate history", "Urban fantasy", "Steampunk", "Magical realism", "WIP", "Complete", "Stub",
       "Main project", "Side project", "Collaborative", "Personal", "High priority", "Low priority", "Needs worldbuilding", "Core concept", "Experimental", "Based on literature"]
    when Vehicle.name
      ["Automobile", "Train", "Plane", "Spaceship", "Ship", "Submarine", "Magical", "Animal-drawn", "Military", "Civilian", "Ancient", "Futuristic", "Unique", "Experimental", "WIP", "Complete", "Stub",
       "Common", "Rare", "Legendary", "Personal", "Public", "Plot device", "Needs illustration", "Science based", "Background detail", "Technology focus"]
    when Document.name
      ['Idea', 'Draft', 'In Progress', 'Done', 'Historical', 'Religious', 'Legal', 'Personal', 'Scientific', 'Map', 'Journal', 'Letter', 'Prophecy', 'Secret', 'WIP', 'Complete', 'Stub',
       'Plot relevant', 'Background lore', 'Ancient', 'Modern', 'Cultural element', 'Needs revision', 'High priority', 'Open for collaboration', 'Based on literature', 'Worldbuilding']
    else
      []
    end
  end
end
