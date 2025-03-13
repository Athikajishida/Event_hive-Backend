class Booking < ApplicationRecord
  belongs_to :customer
  has_many :booking_details, dependent: :destroy
  has_many :tickets, through: :booking_details
  
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
