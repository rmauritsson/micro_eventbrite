# frozen_string_literal: true

class EventAttendeesController < ApplicationController
  def attend
    @event = Event.find(params[:id]).attendees << current_user
    flash[:success] = 'You are attending this event!'
    redirect_to users_show_url
  end
end
