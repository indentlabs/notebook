# JSON endpoint behind the Wordsmith panel in the document editor. Answers
# entirely from the local wordsmith_entries table (see Wordsmith::Lookup).
class WordsmithController < ApplicationController
  before_action :authenticate_user!

  def lookup
    unless Wordsmith::Lookup.available?
      return render json: { available: false }
    end

    # Reference data only changes when the dictionary is re-imported.
    expires_in 1.day

    render json: Wordsmith::Lookup.new(params[:q]).call.merge(available: true)
  end
end
