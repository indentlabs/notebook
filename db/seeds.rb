# ruby encoding: utf-8

def random_name
  name = ''
  12.times { name << ('a'..'z').to_a.sample }
  name.capitalize
end

def random_text
  (['']*10).map { |_| random_name }.join
end

# Every container boot runs this (docker-entrypoint.sh), so everything here
# must be safe to run again: find what's already there instead of creating
# a second copy.
#
# Users are soft-deleted, so look among deleted ones too: creating the same
# email again would fail, and a failing seed stops the container booting.
def seed_user(email:, name:, password:)
  User.with_deleted.find_by(email: email) || User.create!(name: name, email: email, password: password)
end

# The account script/smoke_check.rb signs in as (see docs/release_safety.md).
# It owns a little of each core kind of page so the signed-in crawl has real
# pages to visit. An existing account keeps its password.
tester = seed_user(name: 'Test Test', email: 'test.test@test.test', password: 'testtest')

tester_universe = Universe.find_or_create_by!(name: 'Test Universe', user: tester) do |universe|
  universe.privacy     = 'private'
  universe.description = 'Used by script/smoke_check.rb to check pages after a deploy.'
end
Character.find_or_create_by!(name: 'Test Character', user: tester, universe: tester_universe)
Location.find_or_create_by!(name: 'Test Location', user: tester, universe: tester_universe)
Item.find_or_create_by!(name: 'Test Item', user: tester, universe: tester_universe)
Document.find_or_create_by!(title: 'Test Document', user: tester) do |document|
  document.universe = tester_universe
  document.body     = '<p>Test Character walked into Test Location, carrying Test Item.</p>'
end
Timeline.find_or_create_by!(name: 'Test Timeline', user: tester) do |timeline|
  timeline.universe = tester_universe
end

# Demo authors and their public worlds, for development and staging only:
# their passwords are in this public repository.
unless Rails.env.production?
  tolkien = seed_user(name: 'JRRTolkien', email: 'tolkien@example.com', password: 'speakfriend')

  middleearth = Universe.find_or_create_by!(name: 'Middle-Earth', user: tolkien) do |universe|
    universe.privacy = 'public'
  end

  Character.find_or_create_by!(name: 'Frodo Baggins', user: tolkien, universe: middleearth) do |character|
    character.age = '50'
  end
  Item.find_or_create_by!(name: 'Sting', user: tolkien, universe: middleearth)
  Location.find_or_create_by!(name: 'The Shire', user: tolkien, universe: middleearth)

  rowling = seed_user(name: 'JKRowling', email: 'rowling@example.com', password: 'Alohomora')

  hp_universe = Universe.find_or_create_by!(name: 'The Harry Potter Universe', user: rowling) do |universe|
    universe.privacy = 'public'
  end

  ['Harry Potter', 'Hermione Granger', 'Ron Weasley', 'Albus Dumbledore', 'Lord Voldemort'].each do |character_name|
    Character.find_or_create_by!(name: character_name, user: rowling, universe: hp_universe)
  end

  ['Hogwarts', 'Diagon Alley', 'The Burrow', 'Hogsmeade'].each do |location_name|
    Location.find_or_create_by!(name: location_name, user: rowling, universe: hp_universe)
  end

  ['Elder Wand', 'Invisibility Cloak', 'Resurrection Stone'].each do |item_name|
    Item.find_or_create_by!(name: item_name, user: rowling, universe: hp_universe)
  end
end

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