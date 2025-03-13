class BookingDetail < ApplicationRecord
  belongs_to :ticket
  belongs_to :booking
end
