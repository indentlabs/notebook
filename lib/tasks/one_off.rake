namespace :one_off do
  desc "Create a notification for all users telling them about the new notifications"
  task notifications_announcement: :environment do
    User.all.find_each do |user|
      user.notifications.create(
        message_html: '<div>A new feature is now available:</div><div class="blue-text text-darken-3">Notifications on Notebook.ai</div>',
        icon:         'favorite',
        icon_color:   'red',
        happened_at:  DateTime.current,
        passthrough_link: 'https://medium.com/indent-labs/notifications-on-notebook-ai-693544b676cb'
      )
    end
  end

  desc "Create initial public collections"
  task initial_public_collections: :environment do
    OWNER_USER_ID = 1

    PageCollection.find_or_create_by(
      title: 'The Multiverse',
      # subtitle: 'Browse public universes',
      privacy: 'public',
      page_types: ['Universe'],
      color: Universe.color,
      user_id: OWNER_USER_ID,
      cover_image: "card-headers/universes.jpg"
    )

    PageCollection.find_or_create_by(
      title: 'Bestiary',
      # subtitle: 'Browse public creatures and floras',
      privacy: 'public',
      page_types: ['Creature', 'Flora'],
      color: Creature.color,
      user_id: OWNER_USER_ID,
      cover_image: "card-headers/creatures.jpg"
    )

    PageCollection.find_or_create_by(
      title: 'Atlas',
      # subtitle: 'Browse public locations, planets, continents, countries, towns, and landmarks',
      privacy: 'public',
      page_types: ['Location', 'Planet', 'Continent', 'Country', 'Town', 'Landmark'],
      color: Location.color,
      user_id: OWNER_USER_ID,
      cover_image: "card-headers/locations.jpg"
    )

    PageCollection.find_or_create_by(
      title: 'Pantheon',
      # subtitle: 'Browse public religions and deities',
      privacy: 'public',
      page_types: ['Religion', 'Deity'],
      color: Religion.color,
      user_id: OWNER_USER_ID,
      cover_image: "card-headers/religions.jpg"
    )

    PageCollection.find_or_create_by(
      title: 'The Armory',
      # subtitle: 'Browse public universes',
      privacy: 'public',
      page_types: ['Item', 'Technology', 'Vehicle'],
      color: Item.color,
      user_id: OWNER_USER_ID,
      cover_image: "card-headers/items.jpg"
    )

    PageCollection.find_or_create_by(
      title: 'Calendar',
      # subtitle: 'Browse public universes',
      privacy: 'public',
      page_types: ['Tradition'],
      color: Tradition.color,
      user_id: OWNER_USER_ID,
      cover_image: "card-headers/traditions.jpg"
    )

  end
end
