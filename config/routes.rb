Rails.application.routes.draw do
  get 'users/create'
  get 'users/show'
  get  '/signup',  to: 'users#new'
  post '/signup',  to: 'users#create'
  
  resources :users
end
