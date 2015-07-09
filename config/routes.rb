Rails.application.routes.draw do
  get 'oauth2_callbacks/fitbit' => 'oauth2_callbacks#fitbit'
  get '/users/chart'  => 'users#chart', as: 'user_charts'
  resources :users, only: [:show, :destroy]
  post '/logout/:id' => 'users#logout'
  root to: 'home#index'
end
