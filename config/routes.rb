# frozen_string_literal: true

Rails.application.routes.draw do
  root 'sessions#index'
  post :logout, controller: 'application'

  post 'pick_driver', to: 'appointments#pick_driver', as: :pick_driver
  resources :appointments do
    resources :location
    get :report, on: :member
    post :assign, on: :member
    post :sendReport, on: :member
    patch :cancel, on: :member
  end

  get 'drivers', to: 'drivers#pending'
  get 'drivers_home', to: 'drivers#index'
  get 'drivers_test', to: 'drivers#test'

  # TODO: am i using these?
  post '/appointments/:appointment_id/location/:id/edit', to: 'location#update'
  get 'location/:id/edit', to: 'locations#edit'
  patch 'location/:id/edit', to: 'locations#update'

  get 'driver_availability', to: 'patients#driver_availability', as: :driver_availability
  resources :drivers do
    resources :schedules
    post :claim, on: :member
  end

  get 'patients', to: 'patients#pending'
  get 'patients_home', to: 'patients#index'
  resources :patients do
    resources :presets
    get :comment, on: :member
    get :viewComments, on: :member
    get :defaultAddress, on: :member
    post :saveAddress, on: :member
    patch :append, on: :member
  end

  post 'create_session', to: 'sessions#create'
  resources :sessions

  resources :locations

  match 'admins_home', to: 'admins#index', via: %i[get post]
  post 'admins/add_host'
  resources :admins do
    post :approve, on: :member
    post :unapprove, on: :member
    post :delete_host, on: :member
    post :reset, on: :member
    get :add_host, on: :member
    get :search, on: :member
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
