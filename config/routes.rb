Rails.application.routes.draw do
  root 'sessions#index'
  resources :appointments do
    resources :location
  end
    get 'drivers', to: 'drivers#pending'
    get 'drivers_home', to: 'drivers#index'
    post '/appointments/:appointment_id/location/:id/edit', to: 'location#update'
  resources :drivers
    get 'patients', to:'patients#pending'
    get 'patients_home', to: 'patients#index'
  resources :patients 
  resources :sessions
  resources :admins
  resources :locations

  get 'location/:id/edit', to: 'locations#edit'
  patch 'location/:id/edit', to: 'locations#update'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
