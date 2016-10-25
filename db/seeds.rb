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

affiliation = AttributeCategory.create(name: 'affiliation',
                                       entity_type: 'character',
                                       user: tolkien,
                                       label: 'Affiliation',
                                       icon: 'verified_user')

affiliation.attribute_fields.create(name: 'starting_affiliation',
                                    user: tolkien,
                                    universe: middleearth,
                                    label: 'Starting Affiliation',
                                    field_type: 'text')

affiliation.attribute_fields.create(name: 'ending_affiliation',
                                    user: tolkien,
                                    universe: middleearth,
                                    label: 'Ending Affiliation',
                                    field_type: 'text')
