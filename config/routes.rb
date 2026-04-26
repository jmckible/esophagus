Rails.application.routes.draw do
  get 'up', to: 'rails/health#show', as: :rails_health_check

  get 'login', to: 'sessions#new', as: :login
  post 'authenticate', to: 'sessions#create', as: :authenticate

  namespace :public, path: nil do
    resources :cookbooks
    resources :recipes
  end

  resources :cookbooks
  resources :recipes, path: 'r' do
    resources :cooks, shallow: true
  end

  get 'calendar(/:year/:month)', to: 'calendar#show', as: :calendar,
    constraints: { year: /\d{4}/, month: /\d{1,2}/ }

  resources :sections do
    member do
      patch :move_up
      patch :move_down
    end
  end

  root to: 'recipes#index'
end
