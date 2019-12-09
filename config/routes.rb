Rails.application.routes.draw do
  root 'pages#index'
  get 'event_attendees/attend', to: 'event_attendees#attend'
  #get 'events/show'

  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  get 'users/create'
  get 'users/show', to: 'users#show'

  get  '/signup',  to: 'users#new'
  post '/signup',  to: 'users#create'

  resources :users
  resources :events
  resources :event_attendees
end
