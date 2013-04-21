class GeneratorController < ApplicationController

  # Character

  def character_age
    @upper_limit = 100
    @lower_limit = 2
    
    render :json => rand(@upper_limit - @lower_limit + 1) + @lower_limit
  end

  def character_bodytype
    @possible_types = ["Delicate", "Flat", "Fragile", "Lean", "Lightly muscled", "Small-shouldered", "Thin", "Athletic", "Hourglass", "Bodybuilder", "Rectangular", "Muscular", "Thick-skinned", "Big-boned", "Round physique", "Pear-shaped"]

    render :json => @possible_types[rand(@possible_types.length)]
  end

  def character_eyecolor
    @possible_colors = ["Amber", "Black", "Arctic blue", "Baby blue", "China blue", "Cornflower blue", "Crystal blue", "Denim blue", "Electric blue", "Indigo", "Sapphire blue", "Sky blue", "Champagne brown", "Chestnut brown", "Chocolate brown", "Golden brown", "Honey brown", "Topaz", "Charcoal grey", "Cloudy grey", "Steel grey", "Chartreuse", "Emerald green", "Forest green", "Grass green", "Jade green", "Leaf green", "Sea green", "Hazel", "Amethyst", "Hyacinth", "Ultramarine blue", "One green, one blue", "One blue, one brown", "One brown, one blue", "One brown, one green", "Light violet", "Dark violet"]

    render :json => @possible_colors[rand(@possible_colors.length)]
  end

  def character_facialhair
    @possible_styles = ["Beard, long", "Beard, short", "Chin curtain", "Chinstrap", "Fu Manchu, short", "Fu Manchu, long", "Goatee", "Handlebar mustache", "Horseshoe mustache", "Mustache", "Mutton chops, thin", "Mutton chops, thick", "Neckbeard", "Pencil mustache", "Shenandoah", "Sideburns", "Soul patch", "Light stubble", "Thick stubble", "Toothbrush mustache", "Van Dyke beard", "Patchy beard", "Patchy mustache"]

    render :json => @possible_styles[rand(@possible_styles.length)]
  end

  def character_haircolor
    @possible_colors = ["Blonde", "Black", "Brown", "Red", "Bald", "White", "Grey", "Balding", "Greying", "Bleached", "Blue", "Green", "Purple", "Orange", "Auburn", "Strawberry", "Chestnut", "Dirty Blonde", "Rainbow", "Black tips"]

    render :json => @possible_colors[rand(@possible_colors.length)]
  end

  def character_hairstyle
    @possible_styles = ["Afro", "Bald", "Balding", "Bob cut", "Bowl cut", "Bouffant", "Braided", "Bun", "Butch", "Buzz cut", "Chignon", "Chonmage", "Comb over", "Cornrows", "Crew cut", "Dreadlocks", "Emo", "Fauxhawk", "Feathered", "Flattop", "Fringe", "Liberty Spikes", "Long hair, straight", "Long hair, curly", "Long hair, wavy", "Mohawk", "Mop-top", "Odango", "Pageboy", "Parted", "Pigtails", "Pixie cut", "Pompadour", "Ponytail", "Rattail", "Rocker", "Slicked back", "Spiky, short", "Spiky, long", "Short, curly", "Short, wavy", "Short, thin", "Short, straight"]

    render :json => @possible_styles[rand(@possible_styles.length)]
  end

  def character_height
    @upper_foot_limit = 6
    @lower_foot_limit = 2
    @upper_inch_limit = 11
    @lower_inch_limit = 0

    render :json => [
      rand(@upper_foot_limit - @lower_foot_limit + 1) + @lower_foot_limit,
      "'",
      rand(@upper_inch_limit - @lower_inch_limit + 1) + @lower_inch_limit,
      '"'
      ].join
  end

  def character_identifyingmark
    @possible_marks = ["minor scar", "large scar", "mole", "fleshy growth", "tattoo", "discoloration"]
    @possible_locations = ["left eye", "right eye", "left thigh", "right thigh", "left shin", "right shin", "left foot", "right foot", "big toe", "hip", "stomach", "lower back", "chest", "upper back", "left shoulder", "right shoulder", "left bicep", "right bicep", "left tricep", "right tricep", "left hand", "right hand", "pointer finger", "thumb", "neck", "scalp", "above lip", "nose", "left ear", "right ear", "forehead", "left cheek", "right cheek", "left temple", "right temple", "chin", "beneath chin"]

    render :json => [
      @possible_marks[rand(@possible_marks.length)],
      @possible_locations[rand(@possible_locations.length)]
    ].join(' on the ').capitalize
  end

  def character_name
    @male_first_names = ["James", "John", "Robert", "Michael", "William", "David", "Richard", "Charles", "Joseph", "Thomas", "Christopher", "Daniel", "Paul", "Mark", "Donald", "George", "Kenneth", "Steven", "Edward", "Brian", "Ronald", "Anthony", "Kevin", "Jason", "Matthew", "Gary", "Timothy", "Jose", "Larry", "Jeffrey", "Frank", "Scott", "Eric", "Stephen", "Andrew", "Raymond", "Gregory"]
    @female_first_names = ["Mary", "Patricia", "Linda", "Barbara", "Elizabeth", "Jennifer", "Maria", "Susan", "Margaret", "Margret", "Dorothy", "Lisa", "Nancy", "Karen", "Betty", "Helen", "Sandra", "Donna", "Carol", "Ruth", "Sharon", "Michelle", "Laura", "Sarah", "Kimberly", "Deborah", "Jessica", "Shirley", "Cynthia", "Angela", "Melissa", "Brenda", "Amy", "Anna", "Rebecca", "Virginia", "Kathleen", "Pamela"]
    @last_names = ["Smith", "Brown", "Lee", "Wilson", "Martin", "Patel", "Taylor", "Wong", "Campbell", "Williams", "Thompson", "Jones", "Johnson", "Miller", "Davis", "Garcia", "Rodriguez", "Martinez", "Anderson", "Jackson", "White", "Green", "Lee", "Harris", "Clark", "Lewis", "Robinson", "Walker", "Hall", "Young", "Allen", "Sanchez", "Wright", "King", "Scott", "Roberts", "Carter", "Phillips", "Evans", "Turner", "Torres", "Parker", "Collins", "Stewart", "Flores", "Morris", "Nguyen", "Murphy", "Rivera", "Cook", "Morgan", "Peterson", "Cooper", "Gomez", "Ward"]

    @all_first_names = [] + @male_first_names + @female_first_names
    @all_last_names  = [] + @last_names

    render :json => [
      @all_first_names[rand(@all_first_names.length)],
      @all_last_names[rand(@all_last_names.length)]
    ].join(' ')
  end

  def character_race
    @possible_races = ["Android", "Angel", "Animal", "Arachnoid", "Bird", "Construct", "Dark Elf", "Dwarf", "Elemental", "Elf", "Fairy", "Fey", "Genie", "Gnome", "Half-Dwarf", "Half-Elf", "Half-Orc", "Halfling", "Human", "Insectoid", "Orc", "Reptilian", "Robot", "Spirit", "Vampire", "Werewolf"]

    render :json => @possible_races[rand(@possible_races.length)]
  end

  def character_skintone
    @possible_tones = ["Albino", "Light", "Pale white", "Fair", "White", "Medium", "Olive", "Moderate brown", "Brown", "Dark brown", "Black"]

    render :json => @possible_tones[rand(@possible_tones.length)]
  end

  def character_weight
    @upper_limit = 240
    @lower_limit = 80

    render :json => rand(@upper_limit - @lower_limit + 1) + @lower_limit
  end

  # Location

  def location_name
    @prefixes = ["New", "Los", "Fort", "City of", "El", "Saint", "Des", "Little", "Big", "North", "East", "South", "West", "Round", "The", "Broken", "Santa"]
    @postfixes = ["Port", "City", "Grove", "Pines", "Falls", "Heights", "Oaks", "Rapids", "Valley", "Mountains", "Peaks", "Arbor", "Mesa", "Gardens", "Palms", "Beach", "Bend", "Ruins"]
    @syllables = ["lo", "chi", "ca", "go", "hou", "ston", "nix", "pho", "an", "ant", "ton", "io", "san", "die", "dia", "dal", "las", "son", "vil", "pol", "ral", "polis", "na", "aus", "tin", "fran", "cis", "co", "col", "umb", "bus", "cha", "mem", "phis", "sea", "wor", "the", "tha", "den", "was", "bal", "ti", "mo", "ash", "wau", "kee", "ki", "ru", "lu", "cest", "pro", "ora", "ode", "mu", "ill", "ville", "vil"]
    
    @prefix_occurrence = 0.15
    @postfix_occurrence = 0.15
    @syllables_upper_limit = 4
    @syllables_lower_limit = 2
    
    # Generate root name
    @root_name = ""
    syllables = rand(@syllables_upper_limit - @syllables_lower_limit + 1) + @syllables_lower_limit
    syllables.times do |i|
      @root_name = @root_name + @syllables[rand(@syllables.length)]
    end
    @root_name = @root_name.titleize
    
    # Add prefix/postfix
    added = false
    trigger = rand(100)
    if trigger <= @prefix_occurrence * 100
      added = true
      @root_name = @prefixes[rand(@prefixes.length)] + " " + @root_name
    end
    
    trigger = rand(100)
    if trigger <= @postfix_occurrence * 100 and not added
      added = true
      @root_name = @root_name + " " + @postfixes[rand(@postfixes.length)]
    end
    
    render :json => @root_name
  end

  # Equipment

  def equipment_armor
    # TODO just make this an aggregate of armor and pick randomly from the different ones
    render :json => {}
  end

  def equipment_armor_shield 
    @shield_types = ["Greek aspis", "Buckler", "Heater shield", "Heraldic shield", "Leather shield", "Hide shield", "Hoplon shield", "Kite shield", "Scutum", "Targe"]

    render :json => @shield_types[rand(@shield_types.length)]
  end

  def equipment_weapon
    #TODO just make this an aggregate and pick randomly from the different weapon generators
    @weapon_types = ["Bastard sword", "Battleaxe", "Bolas", "Bow & Arrow", "Bowstaff", "Brass knuckles", "Broom", "Chainsaw", "Club", "Dagger", "Darts", "Falchion", "Flail", "Gauntlet", "Glaive", "Greataxe", "Greatsword", "Halberd", "Handaxe", "Hand crossbow", "Heavy crossbow", "Javelin", "Kama", "Kukri", "Lance", "Longbow", "Longsword", "Madu", "Morningstar", "Net", "Nunchaku", "Pocket knife", "Quarterstaff", "Ranseur", "Rapier", "Repeating crossbow", "Sai", "Sap", "Scimitar", "Scythe", "Shortsword", "Shortbow", "Shortspear", "Shuriken", "Siangham", "Sickle", "Sling", "Spear", "Throwing axe", "Trident", "Warhammer", "Whip"]

    render :json => @weapon_types[rand(@weapon_types.length)]
  end

  def equipment_weapon_axe
    @axe_types = ["Bardiche", "Battleaxe", "Broadaxe", "Handaxe", "Hatchet", "Long-bearded axe", "Tomahawk"]

    render :json => @axe_types[rand(@axe_types.length)]
  end

  def equipment_weapon_bow
    @bow_types = ["Longbow", "Sling", "Blowgun", "Flatbow", "Composite bow", "Yumi", "Gungdo", "Shortbow", "Arbalest", "Crossbow", "Repeating crossbow"]

    render :json => @bow_types[rand(@bow_types.length)]
  end

  def equipment_weapon_club
    @club_types = ["Boomerang", "Frying pan", "Hammer", "Brick", "Mace", "Morningstar", "Sai", "Scepter", "Sledgehammer", "Lamp", "Glass bottle", "Warhammer", "Wrench", "Crowbar"]

    render :json => @club_types[rand(@club_types.length)]
  end

  def equipment_weapon_fist
    @fist_weapon_types = ["Bahh nakh, tiger claws", "Brass knuckles", "Cestus", "Deer horn knives", "Finger knife", "Gauntlets", "Katar", "Korean fan", "Madu, buckhorn stick", "Pata sword gauntlet", "Push dagger", "Roman scissor", "War fan", "Wind and fire wheels", "Emei daggers", "Large stone", "Brick"]

    render :json => @fist_weapon_types[rand(@fist_weapon_types.length)]
  end

  def equipment_weapon_flexible
    @flexible_types = ["Bullwhip", "Cat o' nine tails", "Chain whip", "Lasso", "Nunchaku", "Flail", "Meteor hammer"]

    render :json => @flexible_types[rand(@flexible_types.length)]
  end

  def equipment_weapon_thrown
    @thrown_types = ["Harpoon", "Bolas", "Javelin", "Pilum", "Woomera", "Angon", "Chakram", "Kunai", "Boomerang", "Throwing knife", "Thrown darts", "Swiss arrow", "Francisca", "Tomahawk", "Shuriken", "Stones"]

    render :json => @thrown_types[rand(@thrown_types.length)]
  end

  def equipment_weapon_polearm
    @polearm_types = ["Bo", "Taiji staff", "Quarterstaff", "Staff", "Spear", "Lance", "Pike", "Pitchfork", "Qiang", "Ranseur", "Spetum", "Swordstaff", "Trident", "Bardiche", "Bill", "Glaive", "Halberd", "Lochaber axe", "Naginata", "Partizan", "Scythe", "Voulge", "War scythe"]

    render :json => @polearm_types[rand(@polearm_types.length)]
  end

  def equipment_weapon_shortsword
    @shortsword_types = ["Dagger", "Fireplace poker", "Small sword", "Xiphos shortsword", "Aikuchi shortsword", "Kodachi shortsword", "Pinuti shortsword", "Wakizashi shortsword"]

    render :json => @shortsword_types[rand(@shortsword_types.length)]
  end

  def equipment_weapon_sword
    @sword_types = ["Cutlass", "Dao", "Dha", "Falchion", "Hunting sword", "Kukri", "Pulwar", "Sabre", "Scimitar", "Shamshir", "Talwar", "Epee", "Flamberge", "Longsword", "Ninjato", "Rapier", "Katana", "Claymore", "Dadao", "Executioner's sword", "Flambard", "Greatsword", "Nodachi", "Falcata", "Machete", "Yatagan"]

    render :json => @sword_types[rand(@sword_types.length)]
  end

end









