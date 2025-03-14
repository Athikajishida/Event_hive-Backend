# @file app/controllers/tickets_controller.rb
# @description API Controller for managing ticket resources, including creation, retrieval, update, and deletion.
#              Supports role-based access control using Pundit policies.
#              Nested resource under events to facilitate ticket management for specific events.
#              Provides inventory management for ticket quantities.
# @version 1.0.0 - Initial implementation with CRUD operations for tickets.
# @authors
#  - Athika Jishida

class TicketsController < ApplicationController
  before_action :set_event
  before_action :set_ticket, only: [:show, :update, :destroy]
  
  # @method GET /events/:event_id/tickets
  # @description Retrieves all tickets for a specific event.
  # @param event_id [Integer] The ID of the event to retrieve tickets for.
  # @returns [JSON] List of tickets for the specified event.
  def index
    @tickets = @event.tickets
    render json: @tickets
  end
  
  # @method GET /events/:event_id/tickets/:id
  # @description Retrieves a specific ticket for a specific event.
  # @param event_id [Integer] The ID of the event the ticket belongs to.
  # @param id [Integer] The ID of the ticket to retrieve.
  # @returns [JSON] The ticket details.
  def show
    render json: @ticket
  end
  
  # @method POST /events/:event_id/tickets
  # @description Creates a new ticket for a specific event.
  #              Requires authorization as the event organizer who created the event.
  # @param event_id [Integer] The ID of the event to create a ticket for.
  # @param name [String] The name or type of the ticket (e.g., "General Admission", "VIP").
  # @param price [Decimal] The price of the ticket.
  # @param quantity [Integer] The number of tickets available for sale.
  # @returns [JSON] The created ticket details or error messages.
  def create
    @ticket = @event.tickets.new(ticket_params)
    authorize @ticket
    
    if @ticket.save
      render json: @ticket, status: :created
    else
      render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # @method PATCH/PUT /events/:event_id/tickets/:id
  # @description Updates an existing ticket for a specific event.
  #              Requires authorization as the event organizer who created the event.
  # @param event_id [Integer] The ID of the event the ticket belongs to.
  # @param id [Integer] The ID of the ticket to update.
  # @param name [String] The name or type of the ticket.
  # @param price [Decimal] The price of the ticket.
  # @param quantity [Integer] The number of tickets available for sale.
  # @returns [JSON] The updated ticket details or error messages.
  def update
    authorize @ticket
    
    if @ticket.update(ticket_params)
      render json: @ticket
    else
      render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # @method DELETE /events/:event_id/tickets/:id
  # @description Deletes an existing ticket for a specific event.
  #              Requires authorization as the event organizer who created the event.
  #              Cannot delete tickets that have already been booked.
  # @param event_id [Integer] The ID of the event the ticket belongs to.
  # @param id [Integer] The ID of the ticket to delete.
  # @returns [HTTP Status] 204 No Content on success.
  def destroy
    authorize @ticket
    @ticket.destroy
    head :no_content
  end
  
  private
  
  # @method set_event
  # @description Sets the @event instance variable based on the provided event_id.
  # @param event_id [Integer] The ID of the event to retrieve.
  # @returns [Event] The event object.
  def set_event
    @event = Event.find(params[:event_id])
  end
  
  # @method set_ticket
  # @description Sets the @ticket instance variable based on the provided ID and event.
  # @param id [Integer] The ID of the ticket to retrieve.
  # @returns [Ticket] The ticket object.
  def set_ticket
    @ticket = @event.tickets.find(params[:id])
  end
  
  # @method ticket_params
  # @description Whitelists allowed parameters for ticket creation and update.
  # @returns [ActionController::Parameters] The filtered parameters.
  def ticket_params
    params.permit(:name, :price, :quantity)
  end
end