# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :logged_in?, only: %i[create destroy]

  def index
    @event = if params[:filter] == 'user'
               current_user.events # user ID here
             else
               Event.all
             end
  end

  def new
    @event = Event.new
  end

  def show
    @event = Event.find(params[:id])
    @list = @event.attendees
  end

  def create
    @event = current_user.events.build(event_params)
    if @event.save
      flash[:success] = 'Your Event has been created!'
      redirect_to users_show_url
    else
      render 'new'
    end
  end

  def destroy; end

  private

  def event_params
    params.require(:event).permit(:title, :location, :date, :description)
  end
end
