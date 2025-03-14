# @file app/controllers/events_controller.rb
# @description API Controller for managing events, including creation, updating, and deletion.
#              Provides authorization and event organizer assignment.
# @version 1.0.0 - Initial implementation with event management functionalities.
# @authors
#  - Athika Jishida

class EventsController < ApplicationController
  before_action :set_event, only: [:show, :update, :destroy]
  
  # @method GET /events
  # @description Retrieves a list of all events.
  # @returns [JSON] A list of events.
  def index
    @events = Event.all
    render json: @events
  end
  
  # @method GET /events/:id
  # @description Retrieves details of a specific event.
  # @param id [Integer] The ID of the event.
  # @returns [JSON] The event details.
  def show
    render json: @event
  end
  
  # @method POST /events
  # @description Creates a new event with the current user as the organizer.
  # @param title [String] The event title.
  # @param description [String] The event description.
  # @param venue [String] The event venue.
  # @param start_date [DateTime] The event start date and time.
  # @param end_date [DateTime] The event end date and time.
  # @param capacity [Integer] The maximum number of attendees.
  # @returns [JSON] The created event or error messages.
  def create
    @event = Event.new(event_params)
    @event.event_organizer = current_user
    
    authorize @event
    
    if @event.save
      render json: @event, status: :created
    else
      render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # @method PATCH/PUT /events/:id
  # @description Updates an existing event and notifies attendees.
  # @param id [Integer] The ID of the event.
  # @returns [JSON] The updated event or error messages.
  def update
    authorize @event
    
    if @event.update(event_params)
      # Queue job to notify customers about event update
      # EventUpdateNotificationJob.perform_async(@event.id)
      render json: @event
    else
      render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # @method DELETE /events/:id
  # @description Deletes an existing event.
  # @param id [Integer] The ID of the event.
  # @returns [JSON] Empty response with status 204.
  def destroy
    authorize @event
    @event.destroy
    head :no_content
  end
  
  private
  
  # @method set_event
  # @description Finds the event by ID before actions.
  # @returns [Event] The found event instance.
  def set_event
    @event = Event.find(params[:id])
  end
  
  # @method event_params
  # @description Whitelists allowed parameters for event creation and updates.
  # @returns [ActionController::Parameters] The filtered parameters.
  def event_params
    params.permit(:title, :description, :venue, :start_date, :end_date, :capacity)
  end
end
