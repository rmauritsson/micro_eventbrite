class EventsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  def new
    @event = Event.new
  end

  def show
  end

  def create
    @event = current_user.events.build(event_params)
    if @event.save
      flash[:success] = "Event created!"
      redirect_to events_show_url
    else
      render 'new'
    end
  end

  def destroy
  end

  private

    def event_params
      params.require(:event).permit(:description)
    end
end
