Rails.application.routes.draw do
  root 'sessions#index'
  resources :appointments
    get 'drivers', to: 'drivers#pending'
    get 'drivers_home', to: 'drivers#index'
  resources :drivers
    get 'patients', to:'patients#pending'
    get 'patients_home', to: 'patients#index'
  resources :patients do
    resources :location
  end
  resources :sessions
  resources :admins

  get 'location/:id/edit', to: 'locations#edit'
  patch 'location/:id/edit', to: 'locations#update'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
