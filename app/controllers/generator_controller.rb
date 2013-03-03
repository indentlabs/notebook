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
end
