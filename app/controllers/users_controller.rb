class UsersController < ApplicationController
  skip_before_action :authorized, only: [:create, :show]

  def index
    users = User.all
    render json: users
  end

  def create
    user = User.create(user_params)

    if user.valid?
      my_token = encode_token({user_id: user.id})
      render json: {user: UserSerializer.new(user), token: my_token}
    else
      render json: {error: "Email must be unique."}
    end
  end

  def show
    user = User.find(params[:id])

    render json: {user: UserSerializer.new(user)}
  end

  def update
    user = User.find(params[:id])
    user.update(user_params)

    render json: {user: UserSerializer.new(user)}
  end

  def destroy
    User.find(params[:id]).destroy

    render json: {message: "account deleted"}
  end

  #logged in user
  def profile
    render json: {user: UserSerializer.new(current_user)}, status: :accepted
  end

  private

  def user_params
    params.permit(:email, :password)
  end
end
