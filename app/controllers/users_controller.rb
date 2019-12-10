# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :restrict_access, only: %i[index show]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash.now[:success] = 'Welcome to Micro Eventbrite!'
      log_in(@user)
      redirect_to @user
    else
      render 'new'
    end
  end

  def show
    @user = User.find(current_user.id)
    @events = @user.events
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def restrict_access
    redirect_to login_path unless current_user
  end
end
