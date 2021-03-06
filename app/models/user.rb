# frozen_string_literal: true

class User < ApplicationRecord
  include EventsHelper
  has_many :events, foreign_key: 'creator_id', dependent: :destroy
  has_many :event_attendees, foreign_key: :attendee_id
  has_many :attended_events, through: :event_attendees

  before_save { self.email = email.downcase }

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }
end
