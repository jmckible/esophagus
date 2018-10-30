Rails.application.routes.draw do

  get 'login', to: 'sessions#new', as: :login
  post 'authenticate', to: 'sessions#create', as: :authenticate

  resources :recipes

  root to: 'recipes#index'
end
