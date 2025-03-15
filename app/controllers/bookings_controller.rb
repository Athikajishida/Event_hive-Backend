# @file app/controllers/bookings_controller.rb
# @description API Controller for managing booking resources, including creation, retrieval, and cancellation.
#              Supports role-based access control for customers and event organizers.
#              Includes transaction management for booking creation and cancellation.
# @version 1.0.0 - Initial implementation with CRUD operations and booking confirmation.
# @authors
#  - Athika Jishida

class BookingsController < ApplicationController
  before_action :set_booking, only: [ :show ]

  # @method GET /bookings
  # @description Retrieves all bookings for the current user based on their role.
  #              Customers can see their own bookings.
  #              Event organizers can see bookings for events they created.
  # @returns [JSON] List of bookings with associated booking details and tickets.
  def index
    if @user_type == "customer"
      @bookings = current_user.bookings
    elsif @user_type == "event_organizer"
      # Event organizers can see bookings for their events
      @bookings = Booking.joins(booking_details: { ticket: :event })
                         .where(tickets: { events: { event_organizer_id: current_user.id } })
                         .distinct
    end

    render json: @bookings, include: [ booking_details: { include: :ticket } ]
  end

  # @method GET /bookings/:id
  # @description Retrieves a specific booking by ID with authorization checks.
  # @param id [Integer] The ID of the booking to retrieve.
  # @returns [JSON] The booking details with associated booking details and tickets.
  def show
    authorize @booking
    render json: @booking, include: [ booking_details: { include: :ticket } ]
  end

  # @method POST /bookings
  # @description Creates a new booking with the specified tickets.
  #              Performs validations, calculates total price, and updates ticket inventory.
  #              Sends a confirmation email asynchronously.
  # @param booking_details [Array] Array of objects with ticket_id and quantity.
  # @returns [JSON] The created booking details or error messages.
  def create
    # Ensure user is a customer
    unless @user_type == "customer"
      return render json: { error: "Only customers can create bookings" }, status: :forbidden
    end

    @booking = Booking.new(customer: current_user)
    authorize @booking

    # Initialize total price
    total_price = 0

    # Check if all tickets are available in sufficient quantities
    booking_details_params = params[:booking_details]

    if booking_details_params.blank?
      return render json: { error: "No tickets specified for booking" }, status: :unprocessable_entity
    end

    ActiveRecord::Base.transaction do
      begin
        booking_details_params.each do |detail|
          ticket = Ticket.find(detail[:ticket_id])
          quantity = detail[:quantity].to_i

          if quantity <= 0
            raise ArgumentError, "Quantity must be greater than zero for ticket: #{ticket.name}"
          end

          if ticket.quantity < quantity
            raise ArgumentError, "#{ticket.name} has insufficient availability (requested: #{quantity}, available: #{ticket.quantity})"
          end

          # Calculate price for this ticket
          total_price += ticket.price * quantity
        end

        # Set total price for the booking
        @booking.total_price = total_price

        if @booking.save
          # Create booking details and update ticket quantities
          booking_details_params.each do |detail|
            ticket = Ticket.find(detail[:ticket_id])
            quantity = detail[:quantity].to_i

            # Create booking detail
            @booking.booking_details.create!(
              ticket: ticket,
              quantity: quantity
            )

            # Update ticket quantity
            ticket.update!(quantity: ticket.quantity - quantity)
          end

          # Queue job to send booking confirmation email
          # BookingConfirmationJob.perform_async(@booking.id)

          render json: {
            message: "Booking created successfully",
            booking: @booking.as_json(include: [ booking_details: { include: :ticket } ])
          }, status: :created
        else
          raise ActiveRecord::Rollback, @booking.errors.full_messages.join(", ")
        end

      rescue ActiveRecord::RecordNotFound => e
        raise ActiveRecord::Rollback, "Ticket not found"
      rescue ArgumentError => e
        raise ActiveRecord::Rollback, e.message
      rescue => e
        raise ActiveRecord::Rollback, "An unexpected error occurred: #{e.message}"
      end
    end

    # If we get here with errors, the transaction was rolled back
    if @booking.new_record?
      render json: { error: $! || "Failed to create booking" }, status: :unprocessable_entity
    end
  end

  # @method DELETE /bookings/:id
  # @description Cancels a booking if it was created within the last 24 hours.
  #              Returns tickets to inventory and sends a cancellation notification.
  # @param id [Integer] The ID of the booking to cancel.
  # @returns [JSON] Success message or error message.
  def destroy
    @booking = Booking.find(params[:id])
    authorize @booking

    if Time.now < @booking.created_at + 24.hours
      ActiveRecord::Base.transaction do
        # Return tickets to inventory
        @booking.booking_details.each do |detail|
          ticket = detail.ticket
          ticket.update!(quantity: ticket.quantity + detail.quantity)
        end

        @booking.destroy
        # BookingCancellationJob.perform_async(current_user.id, @booking.id)
      end

      render json: { message: "Booking cancelled successfully" }, status: :ok
    else
      render json: { error: "Bookings can only be cancelled within 24 hours of creation" }, status: :unprocessable_entity
    end
  end

  private

  # @method set_booking
  # @description Sets the @booking instance variable based on the user's role.
  #              Customers can only access their own bookings.
  #              Event organizers can access bookings for their events.
  # @param id [Integer] The ID of the booking to retrieve.
  # @returns [Booking] The booking object.
  def set_booking
    if @user_type == "customer"
      @booking = current_user.bookings.find(params[:id])
    elsif @user_type == "event_organizer"
      # Event organizers can only see bookings for their events
      @booking = Booking.joins(booking_details: { ticket: :event })
                       .where(tickets: { events: { event_organizer_id: current_user.id } })
                       .find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Booking not found" }, status: :not_found
  end

  # @method booking_params
  # @description Whitelists allowed parameters for booking creation.
  # @returns [ActionController::Parameters] The filtered parameters.
  def booking_params
    params.permit(booking_details: [ :ticket_id, :quantity ])
  end
end
