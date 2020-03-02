Rails.application.routes.draw do
  root 'sessions#index'
  resources :appointments
  resources :drivers
  resources :patients
  resources :sessions
  resources :admins
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
