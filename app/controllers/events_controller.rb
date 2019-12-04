class EventsController < ApplicationController
  before_action :logged_in?, only: [:create, :destroy]

  def index
    @event = Event.all
  end
  
  def new
    @event = Event.new
  end

  def show
    @event = Event.find(params[:id])
  end

  def create
    @event = current_user.events.build(event_params)
    if @event.save
      flash[:success] = "Event created!"
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
