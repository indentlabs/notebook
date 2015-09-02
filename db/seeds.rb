# ruby encoding: utf-8

tolkien = User.create(name: 'JRRTolkien',
                      email: 'tolkien@example.com',
                      password: 'Mellon')

middleearth = Universe.create(name: 'Middle-Earth',
                              user: tolkien,
                              privacy: 'public')

Character.create(name: 'Frodo Baggins',
                 user: tolkien,
                 universe: middleearth,
                 age: '50')

Equipment.create(name: 'Sting',
                 user: tolkien,
                 universe: middleearth)

Location.create(name: 'The Shire',
                user: tolkien,
                universe: middleearth)

Language.create(name: 'Sindarin',
                user: tolkien,
                universe: middleearth)

Magic.create(name: 'Wizard Magic',
             user: tolkien,
             universe: middleearth)
