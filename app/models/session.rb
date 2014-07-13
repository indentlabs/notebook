class Session < ActiveRecord::Base
  def create
    Session.create(params.permit!)
  end
end
