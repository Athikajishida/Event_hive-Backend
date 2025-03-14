Rails.application.routes.draw do
  resources :bookings, only: [:index, :show, :create]
  # resources :tickets, only: [:index, :show, :create, :update, :destroy]
  resources :events, only: [:index, :show, :create, :update, :destroy] do
    resources :tickets, only: [:index, :show, :create, :update, :destroy]
  end
  resources :customers, only: [:create]
  resources :event_organizers, only: [:create]  # This will allow POST requests

  post '/auth/login', to: 'authentication#login'

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
