class Equipment < ActiveRecord::Base
  def create
    Equipment.create(params.permit!)
  end
end
