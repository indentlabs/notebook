namespace :one_off do
  desc "Alert users who've saved at least one tree"
  task trees_notification: :environment do
    reference_code = 'green-trees'

    User.find_each do |user|
      trees = GreenService.total_trees_saved_by(user)
    
      if trees >= 1
        user.notifications.create!(
          message_html: "<div>You've saved #{trees.round} tree#{'s' if trees.round > 1} by going digital!</div><div class='blue-text text-darken-3'>That's AWESOME! Click here to see how.</div>",
          icon:         'park',
          icon_color:   'green',
          happened_at:  DateTime.current,
          passthrough_link: 'https://www.notebook.ai/my/data/green',
          reference_code: reference_code
        ) unless user.notifications.where(reference_code: reference_code).any?
      end
    end
  end
  
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
    OWNER_USER_ID = 5

    PageCollection.find_or_create_by(
      title: 'The Multiverse',
      # subtitle: 'Browse public universes',
      privacy: 'public',
      page_types: ['Universe'],
      color: Universe.color,
      user_id: OWNER_USER_ID,
      cover_image: "card-headers/universes.webp",
      description: "The Multiverse is for all of our universes. It's a single, public index — a starting point, if you will — for the wonderful worlds of Notebook.ai.\n\nWhether it's sci-fi or modern, fantasy or fairy tale, modern or horror, original content or alternate universes — your universe is welcome in the Multiverse. Just make sure it's all filled out and has all kinds of pages to continue getting lost in from the universe's page!"
    )

    PageCollection.find_or_create_by(
      title: 'Superheroes',
      # subtitle: 'Browse public creatures and floras',
      privacy: 'public',
      page_types: ['Character'],
      color: Character.color,
      user_id: OWNER_USER_ID,
      cover_image: "https://i.imgur.com/nuRMRNV.jpg",
      description: "Who's the most super of the superheroes in your world? Let's build a collection of the best of the best!"
    )

    PageCollection.find_or_create_by(
      title: 'Supervillains',
      # subtitle: 'Browse public creatures and floras',
      privacy: 'public',
      page_types: ['Character'],
      color: Character.color,
      user_id: OWNER_USER_ID,
      cover_image: "https://i.imgur.com/JGZTuuE.jpg",
      description: "Who' the baddest baddie you've got? Fill out your supervillain's notebook page and then submit them here; let's build a collection of every world's worst villains!"
    )

    PageCollection.find_or_create_by(
      title: 'The Bestiary',
      # subtitle: 'Browse public creatures and floras',
      privacy: 'public',
      page_types: ['Creature', 'Flora'],
      color: Creature.color,
      user_id: OWNER_USER_ID,
      cover_image: "card-headers/creatures.webp",
      description: "The Bestiary is a collection of life.\n\nSubmit your creatures from all your universes, big or small, and then submit your plant life too!"
    )

    PageCollection.find_or_create_by(
      title: 'The Atlas',
      # subtitle: 'Browse public locations, planets, continents, countries, towns, and landmarks',
      privacy: 'public',
      page_types: ['Location', 'Planet', 'Continent', 'Country', 'Town', 'Landmark'],
      color: Location.color,
      user_id: OWNER_USER_ID,
      cover_image: "card-headers/locations.webp",
      description: "The Atlas is a public collection for the locations in our worlds.\n\nYou can submit locations, planets, continents, countries, towns, and landmarks! Let's fill the atlas up with a rich shared world populated with locations around the multiverse."
    )

    PageCollection.find_or_create_by(
      title: 'The Pantheon',
      # subtitle: 'Browse public religions and deities',
      privacy: 'public',
      page_types: ['Religion', 'Deity'],
      color: Religion.color,
      user_id: OWNER_USER_ID,
      cover_image: "card-headers/religions.webp",
      description: "We can build a collective pantheon of gods and goddesses by submitting our deity and religion pages to this collection. Feel free to have your characters take up any the religions shared here!"
    )

    PageCollection.find_or_create_by(
      title: 'The Armory',
      # subtitle: 'Browse public universes',
      privacy: 'public',
      page_types: ['Item', 'Technology', 'Vehicle'],
      color: Item.color,
      user_id: OWNER_USER_ID,
      cover_image: "https://i.imgur.com/8RI3EzY.jpg",
      description: "The Armory is a massive arsenal of items, technology, and vehicles. Submit your weapons, armor, tech, and all other implements of war!"
    )

    PageCollection.find_or_create_by(
      title: 'World Calendar',
      # subtitle: 'Browse public universes',
      privacy: 'public',
      page_types: ['Tradition'],
      color: Tradition.color,
      user_id: OWNER_USER_ID,
      cover_image: "card-headers/traditions.webp",
      description: "We're building a giant calendar of all kinds of traditions, events, routines, and important dates. Submit your traditions and let's see if we can fill up a whole year!"
    )

  end

  desc "Create initial public collections"
  task make_everyone_follow_andrew: :environment do
    # Start at the end to minimize overlap with new users since the task started (since new code autofollows)
    User.all.order('id DESC').find_each do |user|
      UserFollowing.create(user_id: user.id, followed_user_id: 5)
    end

  end

  desc "Let premium users know they can make collections"
  task premium_user_collections_notification: :environment do
    User.where(selected_billing_plan_id: [2, 3, 4, 5, 6]).find_each do |user|
      user.notifications.create(
        message_html: '<div>A new feature is now available:</div><div class="blue-text text-darken-3">Users with a Premium subscription can now create Collections.</div>',
        icon:         'favorite',
        icon_color:   PageCollection.color,
        happened_at:  DateTime.current,
        passthrough_link: 'https://www.notebook.ai/collections'
      )
    end
  end
end
