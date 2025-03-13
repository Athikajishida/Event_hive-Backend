class EventOrganizer < ApplicationRecord
  has_secure_password
  has_many :events, dependent: :destroy
  
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
end
