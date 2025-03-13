class BookingDetail < ApplicationRecord
  belongs_to :ticket
  belongs_to :booking
  
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
