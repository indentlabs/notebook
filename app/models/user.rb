class User < ActiveRecord::Base
    def create
    User.create(params.permit!)
  end
end
