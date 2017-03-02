# ruby encoding: utf-8

def random_name
  name = ''
  12.times { name << ('a'..'z').to_a.sample }
  name.capitalize
end

def random_text
  (['']*10).map { |_| random_name }.join
end

tolkien = User.create(name: 'JRRTolkien',
                      email: 'tolkien@example.com',
                      password: 'Mellon')

tester = User.create(
  name: 'Test Test',
  email: 'test.test@test.test',
  password: 'testtest'
)
tester = User.find_by(email: 'test.test@test.test')

middleearth = Universe.create(name: 'Middle-Earth',
                              user: tolkien,
                              privacy: 'public')

Character.create(name: 'Frodo Baggins',
                 user: tolkien,
                 universe: middleearth,
                 age: '50')

Item.create(name: 'Sting',
            user: tolkien,
            universe: middleearth)

Location.create(name: 'The Shire',
                user: tolkien,
                universe: middleearth)

if ENV.fetch('DATA', '').upcase == 'LOTS'
  puts "Creating lots o' data"

  10.times do
    puts "Creating universes"
    5.times do
      Universe.create!(
        user: tester,
        name: random_name,
        description: random_text,
        history: random_text,
        notes: random_text,
        laws_of_physics: random_text,
        magic_system: random_text,
        technologies: random_text
      )
    end

    puts "Creating characters"
    5.times do
      Character.create!(
        user: tester,
        name: random_name,
        role: random_text,
        gender: random_text,
        age: random_text,
        height: random_text,
        weight: random_text,
        haircolor: random_text,
        hairstyle: random_text,
        facialhair: random_text,
        eyecolor: random_text,
        race: random_text,
        skintone: random_text,
        bodytype: random_text,
        mannerisms: random_text,
        birthday: random_text,
        birthplace: Location.all.sample,
        education: random_text,
        background: random_text,
        fave_color: random_text,
        fave_food: random_text,
        fave_possession: random_text,
        fave_weapon: random_text,
        fave_animal: random_text,
        notes: random_text,
        universe: Universe.all.sample,
        archetype: random_text,
        aliases: random_text,
        motivations: random_text,
        flaws: random_text,
        talents: random_text,
        hobbies: random_text,
        personality_type: random_text
      )
    end

    5.times do
      Location.create!(
        user: tester,
        name: random_text,
        type_of: random_text,
        description: random_text,
        population: random_text,
        language: random_text,
        currency: random_text,
        motto: random_text,
        capital: Location.all.sample,
        largest_city: Location.all.sample,
        # notable_cities: Location.all.sample,
        area: random_text,
        crops: random_text,
        located_at: random_text,
        established_year: random_text,
        notable_wars: random_text,
        notes: random_text,
        private_notes: random_text,
        universe: Universe.all.sample,
        laws: random_text,
        climate: random_text,
        founding_story: random_text,
        sports: random_text,
      )
    end
  end
  puts "All done!"

end