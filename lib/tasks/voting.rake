namespace :voting do
  desc "Create initial votables"
  task create_votables: :environment do
    Votable.create(
      name: 'Community Challenges',
      description: 'Submit your worlds to themed challenges that will push your creativity to its limits &mdash; with prizes!',
      icon: 'stars'
    )
    Votable.create(
      name: 'Universe Collaboration',
      description: 'Collaborate and work together with friends and coworkers in your universes &mdash; while staying in control.',
      icon: 'group_work'
    )
    Votable.create(
      name: 'Forums & Chat Rooms',
      description: 'Discuss your worlds and ideas in great detail with other brilliant worldbuilders from all over Earth.',
      icon: 'forum'
    )
    Votable.create(
      name: 'Expert Q&A Sessions',
      description: 'Get any and all of your worldbuilding questions answered by experts on geography, civics, biology, and more.',
      icon: 'live_help'
    )
  end
end