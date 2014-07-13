class Magic < ActiveRecord::Base
  def create
    Magic.create(params.permit!)
  end
end
