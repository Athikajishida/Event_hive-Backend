class EventUpdateNotificationJob
  include Sidekiq::Job

  def perform(event_id)
    event = Event.find_by(id: event_id)
    return unless event

    # Find all customers who have booked tickets for this event
    customers = Customer.joins(bookings: { booking_details: { ticket: :event } })
                       .where(events: { id: event_id })
                       .distinct

    customers.each do |customer|
      # In a real app, you would send an email here
      puts "SENDING EMAIL: Event update notification to #{customer.name}"
      puts "Event: #{event.title} has been updated"
      puts "New details: venue=#{event.venue}, start=#{event.start_date}, end=#{event.end_date}"

      # Log this activity
      Rails.logger.info("Event update notification sent to #{customer.email} for event ##{event_id}")
    end
  end
end
