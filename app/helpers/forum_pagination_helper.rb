# Classes for the forum paginator in app/views/thredded/kaminari.
module ForumPaginationHelper
  FORUM_PAGINATION_BUTTON = 'items-center justify-center h-9 px-3 rounded-md border text-sm font-medium transition-colors'.freeze
  FORUM_PAGINATION_LINK   = 'border-stone-200 dark:border-gray-600 bg-white dark:bg-gray-800 text-stone-700 dark:text-gray-200 ' \
                            'hover:bg-stone-50 dark:hover:bg-gray-700 hover:border-stone-300 dark:hover:border-gray-500'.freeze
  FORUM_PAGINATION_CURRENT = 'border-blue-600 dark:border-blue-500 bg-blue-600 dark:bg-blue-500 text-white'.freeze

  # Stands in for the page number in the page dropdown's URL template; must
  # match forum_pagination.js.
  PAGE_NUMBER_PLACEHOLDER = 987_654_321

  # Numbered pages only show from the sm breakpoint up; small screens use the
  # page dropdown instead.
  def forum_pagination_button_classes(current: false, numbered: false)
    [
      numbered ? 'hidden sm:inline-flex' : 'inline-flex',
      FORUM_PAGINATION_BUTTON,
      current ? FORUM_PAGINATION_CURRENT : FORUM_PAGINATION_LINK
    ].join(' ')
  end

  # Forum collections are paginated with Kaminari, but will_paginate's
  # page_entries_info shadows Kaminari's and expects will_paginate collections.
  # Kaminari's default entry name doesn't pluralize ("all 4 user"), but it
  # pluralizes one we pass in.
  def forum_page_entries_info(collection, entry_name: collection.model_name.human.downcase)
    Kaminari::Helpers::HelperMethods.instance_method(:page_entries_info)
      .bind_call(self, collection, entry_name: entry_name)
  end
end
