class AuthenticationController < ApplicationController
  skip_before_action :authorize_request, only: [:login]


  def login
    entity_type = params[:entity_type]
    email = params[:email]
    password = params[:password]
    
    if entity_type == "event_organizer"
      entity = EventOrganizer.find_by(email: email)
    elsif entity_type == "customer"
      entity = Customer.find_by(email: email)
    else
      return render json: { error: 'Invalid entity type' }, status: :unprocessable_entity
    end
    
    if entity&.authenticate(password)
      token = JsonWebToken.encode(entity_id: entity.id, entity_type: entity_type)
      time = Time.now + 24.hours.to_i
      render json: { token: token, exp: time.strftime("%m-%d-%Y %H:%M"), entity_type: entity_type }, status: :ok
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end
end