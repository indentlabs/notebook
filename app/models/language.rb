class Language < ActiveRecord::Base
  def create
    Language.create(params.permit!)
  end
end
