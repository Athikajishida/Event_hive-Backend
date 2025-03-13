class Ticket < ApplicationRecord
  belongs_to :event
  has_many :booking_details
  
  validates :name, :price, :quantity, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
