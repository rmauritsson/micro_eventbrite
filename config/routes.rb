Rails.application.routes.draw do

  root 'pages#index'
  get 'pages/index'
  get 'event_attendees/attend', to: 'event_attendees#attend'

  get 'users/create'
  get 'users/show', to: 'users#show'

  get  '/signup',  to: 'users#new'
  post '/signup',  to: 'users#create'

  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  resources :users
  resources :events
  resources :event_attendees
end
