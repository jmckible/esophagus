Rails.application.routes.draw do

  get 'login', to: 'sessions#new', as: :login
  post 'authenticate', to: 'sessions#create', as: :authenticate

  resources :recipes do
    resources :cooks, shallow: true
  end

  root to: 'recipes#index'
end
