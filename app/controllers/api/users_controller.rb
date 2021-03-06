module Api
  class UsersController < BaseController
    def index
      users = User.all

      if params[:limit]
        users = users.limit(params[:limit].to_i)
      end
      if params[:offset]
        users = users.offset(params[:offset].to_i)
      end

      render json: users, root: false, each_serializer: self.serializer
    end


    protected

    def serializer
      if signed_in?
        FullUserSerializer
      else
        UserSerializer
      end
    end
  end
end
