Rails.application.routes.draw do
  root 'pages#Index'
  #get 'events/new'
  #get 'events/show'

  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  get 'users/create'
  get 'users/show'

  get  '/signup',  to: 'users#new'
  post '/signup',  to: 'users#create'

  resources :users
  resources :events
end
