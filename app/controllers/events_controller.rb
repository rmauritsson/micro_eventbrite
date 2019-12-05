class EventsController < ApplicationController
  before_action :logged_in?, only: [:create, :destroy]

  def index
    if(params[:filter]== "user")
      @event= current_user.events #user ID here
    else
      @event = Event.all
    end
  end

  def new
    @event = Event.new
  end

  def show
    @event = Event.find(params[:id])
    @list =  @event.attendees
  end

  def create
    @event = current_user.events.build(event_params)
    if @event.save
      flash[:success] = "Your Event has been created!"
      redirect_to events_path
    else
      render 'new'
    end
  end

  def destroy
  end

  private

    def event_params
      params.require(:event).permit(:title, :location, :date, :description)
    end
end
