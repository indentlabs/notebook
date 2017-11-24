namespace :datafill do
  desc "Create 500 randomized characters"
  task characters: :environment do
    owner = User.last

    COLORS = ['Red', 'Green', 'Blue', 'Orange', 'White', 'Black', 'Yellow', 'Purple']

    puts "Creating 500 characters for user #{owner.email}."
    500.times do
      print '.'
      character = Character.create(
        user: owner,
        name: [
          'Alex', 'Bob', 'Carol', 'David', 'Evan', 'Fred', 'George', 'Harry', 'Isaac', 'Jacob', 'Kevin', 'Lars', 'Man', 'Nelly', 'OJ', 'Peter',
          'Dr. Q', 'Rusty', 'Steve', 'Ulysses', 'Victor', 'Wayne', 'Professor X', 'Zed'
        ].sample + ' ' + COLORS.sample,
        role: ['Protagonist', 'Antagonist', 'Foil', 'Supporting Character', 'Background Character'].sample,
        gender: ['Male', 'Female', 'Other'].sample,
        age: (1..100).to_a.sample,
        height: "#{(1..7).to_a.sample}'#{(1..11).to_a.sample}\"",
        weight: (50..350).to_a.sample,
        haircolor: COLORS.sample,
        eyecolor: COLORS.sample,
        skintone: COLORS.sample,
        fave_color: COLORS.sample,
      )
      character.change_events.update_all(user_id: owner.id)
    end
    puts
    puts "Done."
  end
end
