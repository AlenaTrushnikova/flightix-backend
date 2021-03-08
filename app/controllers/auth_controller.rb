class AuthController < ApplicationController
  skip_before_action :authorized, only: [:create]

  # for login
  def create
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      token = encode_token({user_id: user.id})

      render json: {id: UserSerializer.new(user), token: token}
    else
      render json: {error: 'Invalid email or password, please Sign Up'}, status: 401
    end
  end

  def show
    user = User.find(params[:id])

    render json: UserSerializer.new(user)
  end

end