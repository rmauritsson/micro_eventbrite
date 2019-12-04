Rails.application.routes.draw do
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  get 'users/create'
  get 'users/show'
  
  get  '/signup',  to: 'users#new'
  post '/signup',  to: 'users#create'

  resources :users
end
