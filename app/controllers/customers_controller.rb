# @file app/controllers/customers_controller.rb
# @description API Controller for customer user management, including registration.
#              Provides JWT token authentication for customers.
# @version 1.0.0 - Initial implementation with customer registration functionality.
# @authors
#  - Athika Jishida

class CustomersController < ApplicationController
  skip_before_action :authorize_request, only: [:create]
  
  # @method POST /customers
  # @description Creates a new customer account and returns a JWT token.
  # @param name [String] The customer's full name.
  # @param email [String] The customer's email address.
  # @param password [String] The customer's password.
  # @param password_confirmation [String] Password confirmation for validation.
  # @returns [JSON] Success message with JWT token or error messages.
  def create
    @customer = Customer.new(customer_params)
    if @customer.save
      token = JsonWebToken.encode(entity_id: @customer.id, entity_type: 'customer')
      time = Time.now + 24.hours.to_i
      render json: {
        message: 'Customer created successfully',
        token: token,
        exp: time.strftime("%m-%d-%Y %H:%M")
      }, status: :created
    else
      render json: { errors: @customer.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private
  
  # @method customer_params
  # @description Whitelists allowed parameters for customer creation.
  # @returns [ActionController::Parameters] The filtered parameters.
  def customer_params
    params.permit(:name, :email, :password, :password_confirmation)
  end
end