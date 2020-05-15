Rails.application.routes.draw do
  root 'sessions#index'
  post :logout, controller:"application"

  resources :appointments do
    resources :location
    patch :cancel, on: :member
  end

  get 'drivers', to: 'drivers#pending'
  get 'drivers_home', to: 'drivers#index'
  get 'drivers_test', to: 'drivers#test'
  post 'drivers_claim', to: 'drivers#claim'

  #TODO: am i using these?
  post '/appointments/:appointment_id/location/:id/edit', to: 'location#update'
  get 'location/:id/edit', to: 'locations#edit'
  patch 'location/:id/edit', to: 'locations#update'

  resources :drivers do
    resources :schedules
  end

  get 'patients', to:'patients#pending'
  get 'patients_home', to: 'patients#index'
  resources :patients do
    get :comment, on: :member
    patch :append, on: :member
  end

  post 'create_session', to: 'sessions#create'
  resources :sessions

  resources :locations

  match 'admins_home', to: 'admins#index', via: [:get, :post]
  post 'admins/add_host'
  resources :admins do
    post :approve, on: :member
    post :unapprove, on: :member
    post :train, on: :member
    post :approve_patient, on: :member
    post :delete_host, on: :member
    get :add_host, on: :member
    get :search, on: :member
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
