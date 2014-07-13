class Universe < ActiveRecord::Base
  def create
    Universe.create(params.permit!)
  end
  
  belongs_to :user
end
