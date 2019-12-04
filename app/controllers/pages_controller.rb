class PagesController < ApplicationController
  def Index
    @event = Event.all
  end
end
