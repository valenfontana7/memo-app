class UsersController < ApplicationController
  def create
    @user = User.new(create_params)
    if @user.save
      render json: @user
    else
      render json: {"error": "Sign up failed"}
    end
  end
  def login
    user = User.find_by(email: auth_params[:email])
    if user && user.authenticate(auth_params[:password])
      render json: user.auth_token
    else
      render json: {"error": "There was something wrong with your login details"}
    end
  end
  def users
    @users = User.where(status: "active")
    render json: @users, status: :ok 
  end
  private

  def create_params
    params.require(:user).permit(:first_name,:last_name,:email,:password)
  end
  def auth_params
    params.require(:user).permit(:email, :password)
  end
end