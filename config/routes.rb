Rails.application.routes.draw do
  resources :schedules
  resources :appointments
  resources :admins
  resources :drivers
    get 'patients', to:'patients#pending'
    get 'patients_home', to: 'patients#index'
  resources :patients
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
