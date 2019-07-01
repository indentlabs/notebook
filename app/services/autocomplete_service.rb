class AutocompleteService < Service
  # TODO not make this giant case so awful
  # TODO move the literal arrays into Generators that use the translation file

  # DEPRECATED -- todo remove: no longer used
  def self.for_field_name(field_name)
    case field_name
    when 'education'
      %w(None Elementary Highschool College Graduate Diploma Advanced Homeschooled PhD GED Self-taught Highly-educated)
    when 'fave_animal'
      %w(Cats Dogs Wolves Foxes Horses Lions Birds Tigers Deer Dragons Owls Snakes Bears Horses Rabbits Ravens Pandas Eagles Dolphins Bunnies Rabbits Hawks Panthers Elephants Giraffes Turtles Crwos Cheetahs Doves Fish Phoenix Penguins Otters Sharks Butterflies Caterpillars Koalas Puppies Kittens Falcons Bats Sheep Lizards Monkeys Squirrels Unicorns Lynx Humans Sloths)
    when 'fave_color'
      %w(Blue Green Red Purple Black Yellow Pink Orange White Gold Grey Silver Brown Teal Violet Lavender Maroon Navy Crimson Magenta Indigo Burgundy Turquoise Cyan Aqua Scarlet Pitch Peach)
    when 'fave_food'
      %w(Pizza Sushi Steak Pasta Chocolate Apples Chicken Spaghetti Tacos Meat Fish Strawberries Cake Salad Ramen Pancakes Burgers Bread Sweets Lasagna Salmon Coffee Hamburgers Cookies Rice Noodes Curry Waffles Oranges Seafood Lobsters Fries Bacon Cheese Shrimp Pie Peaches Soup Cheesecake Popcorn Fruit Cupcakes Grapes Venison Candy Berries Stew Potatoes Tea Lamb Watermelon Nachos Chinese Pork Donuts Italian Mexican)
    when 'flaws'
      %w(Stubbornness Naivety Prideful Impulsiveness Selfishness Arrogance Recklessness Clumsiness Anger Self-control Anxiety Shiness Insecurities Overprotectiveness Paranoia Pridefulness Perfectionism Bossiness Manipulative Cockiness Laziness Greedy Forgetful Gullible Depression Loyalty Bluntness Hubris Sensitivity Alcoholicism Addictions Cowardly Childish Overconfident Untrusting Anxious Headstrong Rude Oblivious Jealous Proud Hot-headed Secretive Liar)
    when 'gender'
      %w(Male Female Agender Masculino Nonbinary Genderfluid He/Him She/Her Genderless They/Them Unknown Masculine Feminine)
    when 'hobbies'
      %w(Reading Drawing Cooking Gardening Painting Writing Singing Art Dancing Music Hunting Photography Baking Training Running Swimming Diving Knitting Sewing Archery Horsebackriding Reading Sports Sleeping Football Drinking Chess Gaming Basketball Reading Piano Drawing Tinkering Electronics Programming Killing Guitar Running Murder Altruism Volunteering Exploring Adventuring Baseball Magic Flying Boxing Stealing Gambling Painting Whittling Poetry Fighting Quidditch Shopping Violin Stargazing Science)
    when 'identmarks'
      %w(None Freckles Glasses Scars Tattoos Eyes Wings Mouth Ears Hair Mole Fangs Vitiligo Height Weight Clothing)
    when 'item_type'
      t('weapon_types') + t('shield_types') + t('axe_types') + t('bow_types') +
      t('club_types') + t('flexible_weapon_types') + t('fist_weapon_types') + t('thrown_weapon_types') +
      t('polearm_types') + t('shortsword_types') + t('sword_types') + t('other_item_types')
    when 'mannerisms'
      %w(Polite Quiet Kind Shy Angry Rude Brazen Aggressive Paranoid Sarcastic Confident Proper Calm Loud Good Reserved Friendly Sweet Nice Blunt Sassy Figety Formal Protective Nervous Stoic Sly Timid Motherly Twitchy Smiley Stutters Flirty Childish Awkward Arrogant Inappropriate)
    when 'motivations'
      %w(Family Love Power Money Revenge Survival Freedom Justice Friends Honor Adventure Spite Curiosity Love Food Knowledge Altruism Fear Fun Success Loyalty Music Friendship Anger Happiness Greed Security Fame Ambition Winning Boredom Pride Vengeance Kindness Love)
    when 'occupation'
      %w(Student King Queen Princess Prince Assassin Woodsman Programmer Athlete Hunter Soldier Unemployed Teacher Mercenary Doctor Nurse President Adventurer Thief Warrior Farmer Healer Musician Pirate Mechanic Scientist Spy Blacksmith Bartender Waitress Baker Lawyer Guard Knight Barista Marketer Librarian Detective Officer General Guardian Parent Superhero Rebel Artist Writer Witch Engineer Mage Prostitute Singer Designer Preacher Priest Journalist Criminal Florist Merchant Emperor Hunter Chef Fighter Wizard Housewife Caretaker Actor Ruler Bodyguard Seamstress Manager CEO)
    when 'personality_type'
      %w(INTJ INTP ENTJ ENTP INFJ INFP ENFJ ENFP ISTJ ISFJ ESTJ ESFJ ISTP ISFP ESTP ESFP Architect Logician Commander Debater Advocate Mediator Protagonist Campaigner Logistician Defender Executive Consul Virtuoso Adventuer Entrepreneur Entertainer Introverted Extroverted)
    when 'politics'
      %w(Liberal Democrat Republican Conservative Monarchy Anarchist Neutral Independent Central Left Right Rebel Socialist Communist Moderate Apolitical Progressive Labour Undecided)
    when 'religion'
      %w(Atheist Christian Catholic Agnostic Jewish Muslim Judaism Islam Pagan Wiccan Protestant Quaker Satanism Buddhism Baptist Shinto Hinduism Lutheran Mormon Spiritual Polytheism Magic)
    when 'role'
      ['Protagonist', 'Antagonist', 'Main character', 'Supporting character', 'Side character', 'Hero', 'Enemy', 'Wise Old Man', 'Secondary Character', 'Love interest', 'Minor character', 'Villain', 'NPC', 'Ally', 'Father', 'Mother', 'Best friend', 'Background character', 'Companion', 'Deity', 'Healer', 'Warrior', 'Witch', 'Assassin', 'Superhero', 'Brother', 'Sister']
    when 'talents'
      %w(Singing Dancing Magic Drawing Cooking Reading Art Painting Sketching Fighting Writing Listening Archery Blacksmithery Music Healing Piano Guitar Baking Acting Sports Swordfighting Weaponry Manipulation Photography Hunting Survival Running Lying Speaking Persuasion Gardening Shapeshifting Strength Soccer Basketball Chemistry Biology Science Stealth Memory Violin Necromancy Recall Jumping Hopskotch Smoothtalking)
    else
      []
    end.uniq
  end

  # Adding a field label to this switch/case will enable autocompleting
  # for that field across any page type.
  def self.for_field_label(field_label)
    case field_label.downcase
    when 'eye color', 'eyecolor', 'eyecolour', 'eye colour'
      t('eye_colors')
    when 'bodytype', 'body type'
      t('body_types')
    when 'facialhair', 'facial hair'
      t('facial_hair_styles')
    when 'fave weapon', 'weapon', 'favorite weapon', 'favourite weapon'
      t('weapon_types')  + t('shield_types')          + t('axe_types')         + t('bow_types') +
      t('club_types')    + t('flexible_weapon_types') + t('fist_weapon_types') + t('thrown_weapon_types') +
      t('polearm_types') + t('shortsword_types')      + t('sword_types')
    when 'hairstyle', 'hair style'
      t('hair_styles')
    when 'haircolor', 'hair color', 'haircolour', 'hair colour'
      t('hair_colors')
    when 'race'
      t('character_races')
    when 'skintone', 'skin tone', 'skin'
      t('skin_tones')
    else
      []
    end.uniq
  end

  def self.autocompleteable?(field_label)
    self.for_field_label(field_label).any?
  end

  # helper method so we don't have to I18n every time
  def self.t(key)
    I18n.t(key, scope: 'autocomplete')
  end
end
