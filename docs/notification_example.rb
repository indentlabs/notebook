  user = User.find(5)

  User.find_each do |user|
    user.notifications.create(
      message_html:     "<div class='text-darken-4 black-text'>2021 is winding to a close...</div>Click here to see your year in review!",
      icon:             'event_available',
      icon_color:       'blue',
      happened_at:      DateTime.current,
      passthrough_link: "https://www.notebook.ai/my/data/yearly/2021",
      reference_code:   "2021-year-in-review"
    )
  end
