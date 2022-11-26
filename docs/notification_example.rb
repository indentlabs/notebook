  user = User.find(5)

  User.find_each do |user|
    user.notifications.create(
      message_html:     "<strong class='text-darken-4 black-text'>Worldbuilding Competitions:</strong> We're sponsoring two government-building competitions right now. Click for more details.",
      icon:             'event_available',
      icon_color:       'orange',
      happened_at:      DateTime.current,
      passthrough_link: "https://medium.com/indent-labs/utopian-dream-or-dystopian-rule-93abf25ad4eb",
      reference_code:   "thanksgoving-2022"
    )
  end
