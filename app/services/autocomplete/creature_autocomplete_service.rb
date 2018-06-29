class CreatureAutocompleteService < Service
  # TODO not make this giant case so awful
  # TODO move the literal arrays into Generators that use the translation file
  def self.for(field_name)
    case field_name
    when 'type_of'
      %w(Dragon Bird Mammal Reptile Horse Monster Dog Insect Cat Undead Canine Spirit Beast Humanoid Fairy Faerie Wolf Feline Demon Fish Hybrid Animal Snake Horse)
    when 'color'
      # TODO reuse color array here
      %w(Black White Brown Grey Red Green Varies Gray Multicolored Silver Blue Yellow Pale Purple Orange Indigo Violet Transparent)
    when 'shape'
      # TODO include animal array here
      %w(Humanoid Round Square Oblong Long Short Thin Tall Cat Wolf Bird Horse Muscular Canine Butterfly Formless Shapeless Gaseous Liquid)
    when 'size'
      %w(Small Medium Large Big Huge Tiny Human-sized Dog-sized Microscopic Nanoscopic Gargantuan Average)
    when 'notable_features'
      %w(Wings Antennae Antlers Hooves Claws Teeth Eyes Tail Tongue Fur Legs Head Bloody Shiny Transparent Iridescent)
    when 'materials'
      %w(Fur Scales Feathers Chitin Skin Hair Metal Rubber Meteorite Rock Lava Water Ectoplasm Bone Flesh)
    when 'aggressiveness'
      %w(Very Extremely Nonaggressive Passive Pacifist Scared Docile Moderate Threatening Hostile High Low Skittish Neutral Angry)
    when 'attack_method'
      %w(Biting Clawing Running Pecking Headbutting Headgames Mindgames Magic Charging Fire Water Magic Ambushing Fangs Flying Crushing Smothering Scratching)
    when 'defense_method'
      %w(Flying Evasion Running Fleeing Attacking Burrowing Hiding Speed Armor Fire Poison Quills Camouflage Acid)
    when 'strengths'
      %w(Speed Size Poison Armor Defense Intelligence Intellect Flexibility Strength Senses Sight Hearing Vision Stealth Flying Agility Luck)
    when 'weaknesses'
      %w(Fire Water Wind Lightning Predators Silver Gold Bronze None Love Sunlight Poison)
    when 'sounds'
      %w(None Roaring Silent Hissing Barking Chirping Buzzing Yawning Growling Squeaking Howling Screeching Neighing Yipping Purring Cawing)
    when 'spoils'
      %w(None Meat Antlers Thrills Leather Fur Skin Hair Organs Horns Magic Rejuvenation Oil Fuel Feathers Shells Poison Scales Bones Gems Armor Metal Rock Blood Talons)
    when 'preferred_habitat'
      %w(Forest Mountains Desert Underground Plains Cave Ocean River Jungle Tundra Swamp Water Grasslands Hell Space Temples Cities Houses Holes Clouds Sky)
    when 'food_sources'
      %w(None Meat Carnivore Herbivore Omnivore Ash Water Gems Rocks Bones Humans Grass Sunlight Fish Eggs Babies Corpses)
    when 'reproduction'
      %w(None Sexually Asexually Eggs Livebirth Mating Magic Mitosis Cloning Annually Bi-annually Seasonally)
    when 'herd_patterns'
      %w(None Solitary Familial Groups Flocks) + ["Small groups", "Large groups"]
    when 'similar_animals'
      # TODO animal array here
      %w(Dragons Humans Birds Dogs Cats Wolves Deer Horses Spiders Lizards Wyverns Rats Mice Hippogriffs Chimeras Ferrets Foxes Armadillos Mermaids Bats Sheeps Oxen Mules)
    when 'symbolisms'
      # TODO some arrays here
      %w(Love Hate Death Life Loyalty Money Anger Sadness Fear Sneakiness Loathing Selfishness Gratitude Selflessness Destruction Darkness Evil Glory Comfort Companionship Duality Deception None Strength Weakness Secrets Honor Justice)
    else
      []
    end.uniq
  end

  # helper method so we don't have to I18n every time
  def self.t(key)
    I18n.t(key)
  end
end
