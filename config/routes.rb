Rails.application.routes.draw do
  resources :schedules
  resources :appointments
  resources :admins
  resources :drivers
  resources :patients
  resources :sessions
  root 'sessions#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
