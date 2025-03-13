class Customer < ApplicationRecord
  has_secure_password
  has_many :bookings, dependent: :destroy
  
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
end
