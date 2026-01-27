Rails.application.routes.draw do

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

  resources :sections do
    member do
      patch :move_up
      patch :move_down
    end
  end

  root to: 'recipes#index'
end
