  user = User.find(5)

  User.find_each do |user|
    user.notifications.create(
      message_html:     "<div class='text-darken-4 black-text'>New in Notebook.ai:</div>Document tags, folders, and more!",
      icon:             Document.icon,
      icon_color:       Document.color,
      happened_at:      DateTime.current,
      passthrough_link: "https://medium.com/indent-labs/write-and-organize-your-stories-in-notebook-ai-1d7821af6f07",
      reference_code:   "documents-folders-and-tags"
    )
  end
