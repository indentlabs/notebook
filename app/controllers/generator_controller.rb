class GeneratorController < ApplicationController
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
  
  def character_age
    @upper_limit = 100
    @lower_limit = 2
    
    render :json => rand(@upper_limit - @lower_limit + 1) + @lower_limit
  end

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

end









