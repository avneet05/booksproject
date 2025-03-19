


Rails.application.routes.draw do
  # Landing page route
  root "pages#landing"
  get "pages/landing"
  get "pages/books", to: "pages#books", as: :books
  get 'pages/books/:id', to: 'pages#show', as: 'book'

  # User routes
  get 'pages/users', to: 'pages#users', as: 'users'
  get 'pages/users/:id', to: 'pages#user_show', as: 'user'

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end
