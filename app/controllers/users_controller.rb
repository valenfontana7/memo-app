class UsersController < ApplicationController
  def create

  end
  def login
  end
  private

  def create_params
    params.require(:user).permit(:username, :email, :password)
  end
end