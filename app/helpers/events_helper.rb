module EventsHelper
  def created_events(user)
    render(user.events)
  end

  def upcoming(user)
    render(user.attended_events.upcoming)
  end

  def past(user)
    render(user.attended_events.past)
  end
end
