class BookingConfirmationJob
  include Sidekiq::Job

  def perform(booking_id)
    booking = Booking.find_by(id: booking_id)
    return unless booking

    customer = booking.customer
    event = booking.booking_details.first.ticket.event

    # In a real app, you would send an email here
    puts "SENDING EMAIL: Booking confirmation for #{customer.name}"
    puts "Event: #{event.title}"
    puts "Total tickets: #{booking.booking_details.sum(:quantity)}"
    puts "Total price: #{booking.total_price}"

    # Log this activity
    Rails.logger.info("Booking confirmation email sent to #{customer.email} for booking ##{booking_id}")
  end
end
