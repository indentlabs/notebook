class Character < ActiveRecord::Base
  def new
    Character.new
  end
  
  def create
    Character.create(params.require(:character).permit!)
  end
  
  
  
  belongs_to :user
  belongs_to :universe
end
