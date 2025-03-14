# @file app/controllers/event_organizers_controller.rb
# @description API Controller for event organizer user management, including registration.
#              Provides JWT token authentication for event organizers.
# @version 1.0.0 - Initial implementation with event organizer registration functionality.
# @authors
#  - Athika Jishida

class EventOrganizersController < ApplicationController
  skip_before_action :authorize_request, only: [:create]
  
  # @method POST /event_organizers
  # @description Creates a new event organizer account and returns a JWT token.
  # @param name [String] The event organizer's full name.
  # @param email [String] The event organizer's email address.
  # @param password [String] The event organizer's password.
  # @param password_confirmation [String] Password confirmation for validation.
  # @returns [JSON] Success message with JWT token or error messages.
  def create
    @event_organizer = EventOrganizer.new(event_organizer_params)
    if @event_organizer.save
      token = JsonWebToken.encode(entity_id: @event_organizer.id, entity_type: 'event_organizer')
      time = Time.now + 24.hours.to_i
      render json: {
        message: 'EventOrganizer created successfully',
        token: token,
        exp: time.strftime("%m-%d-%Y %H:%M")
      }, status: :created
    else
      render json: { errors: @event_organizer.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private
  
  # @method event_organizer_params
  # @description Whitelists allowed parameters for event organizer creation.
  # @returns [ActionController::Parameters] The filtered parameters.
  def event_organizer_params
    params.require(:event_organizer).permit(:name, :email, :password, :password_confirmation)
  end
end