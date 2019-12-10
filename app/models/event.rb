# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :creator, class_name: 'User'

  has_many :event_attendees, foreign_key: :attended_event_id
  has_many :attendees, through: :event_attendees

  scope :past, -> { where('date < ?', Time.now) }
  scope :upcoming, -> { where('date >= ?', Time.now) }
  scope :today, -> { where('date = ?', Date.today) }
end
