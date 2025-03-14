class ApplicationController < ActionController::API
  include Pundit::Authorization

  before_action :authorize_request
  
  attr_reader :current_user, :user_type
  
  private
  
  def authorize_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    
    begin
      @decoded = JsonWebToken.decode(header)
      entity_id = @decoded[:entity_id]
      entity_type = @decoded[:entity_type]
      
      if entity_type == "event_organizer"
        @current_user = EventOrganizer.find(entity_id)
      elsif entity_type == "customer"
        @current_user = Customer.find(entity_id)
      else
        render json: { errors: ['Invalid token'] }, status: :unauthorized
      end
      
      @user_type = entity_type
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end
end