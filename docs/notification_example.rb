  user = User.find(5)

  User.find_each do |user|
    user.notifications.create(
      message_html:     "<div class='text-darken-4 black-text'><strong>2022 is winding to a close...</strong></div>Clear here to see your Year in Review!",
      icon:             'event_available',
      icon_color:       'blue',
      happened_at:      DateTime.current,
      passthrough_link: "https://www.notebook.ai/my/data/yearly/2022",
      reference_code:   "year-in-review-2022"
    )
  end
