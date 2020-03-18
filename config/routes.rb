Rails.application.routes.draw do

  get 'login', to: 'sessions#new', as: :login
  post 'authenticate', to: 'sessions#create', as: :authenticate

  namespace :public, path: nil do
    resources :cookbooks
    resources :recipes
  end

  resources :cookbooks
  resources :recipes do
    resources :cooks, shallow: true
  end

  resources :sections

  root to: 'recipes#index'
end
