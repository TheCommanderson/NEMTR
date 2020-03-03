Rails.application.routes.draw do
  resources :appointments
    get 'drivers', to: 'drivers#pending'
    get 'drivers_home', to: 'drivers#index'
  resources :drivers
    get 'patients', to:'patients#pending'
    get 'patients_home', to: 'patients#index'
  resources :patients
  resources :admins
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
