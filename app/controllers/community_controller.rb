# Public page celebrating how much the Notebook.ai community writes together.
# Every number shown is an anonymous aggregate; see CommunityStatsService.
class CommunityController < ApplicationController
  def index
    @page_title = "The Notebook.ai writing community"
    set_meta_tags(
      title: @page_title,
      description: "Thousands of writers are building worlds on Notebook.ai. See how many words the community writes together every day."
    )

    @stats = CommunityStatsService.new
    @this_month = Date.current.beginning_of_month
    @last_month = @this_month.prev_month

    if user_signed_in?
      @your_words_today = WordCountUpdate.words_written_on_date(current_user, current_user.current_date_in_time_zone)
    end
  end
end
