Rails.application.routes.draw do
  get 'users/create'
  get 'users/show'
  get  '/signup',  to: 'users#new'
end
