namespace :voting do
  desc "Create initial votables"
  task create_votables: :environment do
    Votable.create(
      name: 'Community Challenges',
      description: [
        'Submit your worlds to themed challenges that will push your creativity to its limits &mdash; with prizes!',
        'With topics spanning from most exotic creatures to outstanding unlikely heroes, there will be challenges for everyone.'
      ].map { |text| "<p>#{text}</p>" }.join,
      icon: 'stars'
    )
    Votable.create(
      name: 'Universe Collaboration',
      description: [
        'Collaborate and work together with friends and coworkers in your universes &mdash; while staying in control.',
        'Let others add their ideas to your universe, or vice versa. Worldbuilding is better with friends.'
      ].map { |text| "<p>#{text}</p>" }.join,
      icon: 'group_work'
    )
    Votable.create(
      name: 'Forums & Chat Rooms',
      description: [
        'Discuss your worlds and ideas in great detail with other brilliant worldbuilders from all over Earth.',
        "Find a community of like-minded worldbuilders with in-depth discussions on what's important to you."
      ].map { |text| "<p>#{text}</p>" }.join,
      icon: 'forum'
    )
    Votable.create(
      name: 'Expert Q&A Sessions',
      description: [
        'Get any and all of your worldbuilding questions answered by experts on geography, civics, biology, and more.',
        "Whether we're submitting questions to an expert or having someone on for a live interview, there's always more to learn."
      ].map { |text| "<p>#{text}</p>" }.join,
      icon: 'live_help'
    )
  end
end