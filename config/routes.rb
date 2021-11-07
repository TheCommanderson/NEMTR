# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'sessions#index'

  # KEEP SORTED #
  resources :appointments do
    resources :locations, only: %i[edit update]
    resources :comments
    member do
      get 'assign'
    end
  end
  resources :drivers do
    resources :schedules, only: %i[index show edit update]
    member do
      get 'waiting'
      post 'approve'
      post 'assign'
    end
  end
  resources :healthcareadmins
  resources :patients do
    resources :locations
    resources :comments
    member do
      get 'appointments'
      post 'approve'
    end
    collection do
      get 'match'
    end
  end
  resources :sessions, only: %i[index new create] do
    collection do
      get 'about'
      get 'involved'
      get 'waiting'
      delete 'logout'
    end
  end
  resources :sysadmins do
    collection do
      get 'vsearch'
      get 'hsearch'
      get 'psearch'
      get 'dsearch'
    end
    member do
      patch 'host'
      delete 'unhost'
    end
  end
  resources :users, only: %i[show edit update] do
    member do
      get 'password'
      get 'availability'
      patch 'reset'
      patch 'submit'
    end
  end
  resources :volunteers do
    member do
      post 'approve'
    end
  end
end
