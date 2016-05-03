# ruby encoding: utf-8

tolkien = User.create(name: 'JRRTolkien',
                      email: 'tolkien@example.com',
                      password: 'Mellon')

tester = User.create(name: 'Test Test',
                     email: 'test@test.test',
                     password: 'testtest')

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
