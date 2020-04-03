Rails.application.routes.draw do
  root 'sessions#index'
  post :logout, controller:"application"

  resources :appointments do
    patch :cancel, on: :member
  end
  
  get 'drivers', to: 'drivers#pending'
  get 'drivers_home', to: 'drivers#index'
  
  resources :drivers do
    resources :schedules
  end
  
  get 'patients', to:'patients#pending'
  get 'patients_home', to: 'patients#index'
  resources :patients
  
  post 'create_session', to: 'sessions#create'
  resources :sessions
  
  get 'admins_home', to: 'admins#index'
  resources :admins

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
