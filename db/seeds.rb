# ruby encoding: utf-8

tolkien = User.create({
  :name => 'JRRTolkien',
  :email => 'tolkien@example.com',
  :password => 'Mellon'})

middleearth = Universe.create({
  :name => 'Middle-Earth',
  :user => tolkien,
  :privacy => 'public'})

frodo = Character.create({
  :name => 'Frodo Baggins',
  :user => tolkien,
  :universe => middleearth,
  :age => '50'})

sting = Equipment.create({
  :name => 'Sting',
  :user => tolkien,
  :universe => middleearth})

# Issues #415 and #416 prevent us from seeding locations
#shire = Location.create({
#  :name => 'The Shire',
#  :user => tolkien,
#  :universe => middleearth})

sindarin = Language.create({
  :name => 'Sindarin',
  :user => tolkien,
  :universe => middleearth})

wizard = Magic.create({
  :name => 'Wizard Magic',
  :user => tolkien,
  :universe => middleearth})