class CreateModels < ActiveRecord::Migration
  def change
    create_table :characters do |t|
      t.string :name, :null => false
      t.string :role
      t.string :gender
      t.string :age

      # Appearance
      t.string :height
      t.string :weight
      t.string :haircolor
      t.string :hairstyle
      t.string :facialhair
      t.string :eyecolor
      t.string :race
      t.string :skintone
      t.string :bodytype
      t.string :identmarks # Identifying marks

      # Social
      t.text :bestfriend
      t.text :religion
      t.text :politics
      t.text :prejudices
      t.text :occupation
      t.text :pets
      #How might others describe him?
      #What would others change about him?

      # Behavior
      t.text :mannerisms
      #What drives this character?
      #What is standing in his way?
      #What is he most afraid of?
      #What does he need most?
      #What makes him vulnerable?
      #What kind of trouble does he get in?

      # History
      t.text :birthday
      t.text :birthplace
      t.text :education
      t.text :background
      #What is his deepest secret?
      #Does he have a history of criminal activity?

      # Favorites
      t.string :fave_color
      t.string :fave_food
      t.string :fave_possession
      t.string :fave_weapon
      t.string :fave_animal
      #favorite leisure activities

      # Relationships
      t.text :father
      t.text :mother
      t.text :spouse
      t.text :siblings
      t.text :archenemy

      # Notes
      t.text :notes
      t.text :private_notes
        
      t.belongs_to :user
      t.belongs_to :universe
      
      t.timestamps
    end
    
    create_table :equipment do |t|
      # General
      t.string :name, :null => false
      t.string :equip_type

      # Appearance
      t.text :description
      t.string :weight

      # History
      t.string :original_owner
      t.string :current_owner
      t.text :made_by
      t.text :materials
      t.string :year_made

      # Abilities
      t.text :magic # Magical Properties

      # Notes
      t.text :notes
      t.text :private_notes
      
      t.belongs_to :user
      t.belongs_to :universe

      t.timestamps
    end
    
    create_table :languages do |t|
      # General
      t.string :name, :null => false

      # Vocabulary
      t.text :words

      # History
      t.string :established_year
      t.string :established_location

      # Speakers
      t.text :characters
      t.text :locations

      # More
      t.text :notes

      t.belongs_to :user
      t.belongs_to :universe

      t.timestamps
    end
    
    create_table :locations do |t|
      # General
      t.string :name, :null => false
      t.string :type_of
      t.text :description

      # Map
      t.attachment :map

      # Culture
      t.string :population
      t.string :language
      t.string :currency
      t.string :motto
      #field :flag, :type => Image
      #field :seal, :type => Image

      # Cities
      t.text :capital
      t.text :largest_city
      t.text :notable_cities

      # Geography
      t.text :area
      t.text :crops
      t.text :located_at

      # History
      t.string :established_year
      t.text :notable_wars

      # Notes
      t.text :notes
      t.text :private_notes

      t.belongs_to :user
      t.belongs_to :universe

      t.timestamps
    end
    
    create_table :magics do |t|
      # General
      t.string :name, :null => false
      t.string :type_of # "Type of": Spell, Ability, Enchantment, etc

      # Appearance
      t.text :manifestation
      t.text :symptoms

      # Alignment
      t.string :element
      t.string :diety

      # Effects
      t.text :harmfulness # Harmful effects
      t.text :helpfulness # Helpful effects
      t.text :neutralness # Neutral effects

      # Requirements
      t.text :resource # Resource required
      t.text :skill_level # Skill required
      t.text :limitations

      # Notes
      t.text :notes
      t.text :private_notes

      t.belongs_to :user
      t.belongs_to :universe

      t.timestamps
    end
    
    create_table :sessions do |t|
      
      t.string :username, :unique => true, :null => false
      t.string :password, :null => false
      
      t.timestamps
    end
    
    create_table :universes do |t|
      # General
      t.string :name, :null => false
      t.text :description

      # History
      t.text :history

      # More...
      t.text :notes
      t.text :private_notes

      # Settings
      t.string :privacy # 'private' or 'public'

      t.belongs_to :user

      t.timestamps
    end
    
    create_table :users do |t|
      t.string :name, :unique => true, :null => false
      t.string :email, :unique => true, :null => false
      t.string :password, :null => false

      t.timestamps
    end
  end
end
