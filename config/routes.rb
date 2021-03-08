Rails.application.routes.draw do
  resources :plans, only: [:index, :create, :show, :update, :destroy]
  resources :users, only: [:index, :show, :update, :destroy]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/tickets', to: 'tickets#index'

  #customs for fetch
  get '/profile', to: 'users#profile'

  #jwt auth
  post '/signup', to: 'users#create'
  post '/login', to: 'auth#create'
  get '/persist', to: 'auth#show'
end
