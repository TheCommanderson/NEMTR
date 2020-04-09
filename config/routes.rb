Rails.application.routes.draw do
  root 'sessions#index'
  post :logout, controller:"application"
  resources :appointments
    get 'drivers', to: 'drivers#pending'
    get 'drivers_home', to: 'drivers#index'
  resources :drivers
    get 'patients', to:'patients#pending'
    get 'patients_home', to: 'patients#index'
  resources :patients
  resources :sessions
    post 'create_session', to: 'sessions#create'
  resources :admins
    get 'admins_home', to: 'admins#index'
    post 'admins_home', to: 'admins#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
