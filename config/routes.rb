Rails.application.routes.draw do
  get 'oauth2_callbacks/fitbit' => 'oauth2_callbacks#fitbit'
  resources :users, only: [:show, :destroy]
  post '/logout/:id' => 'users#logout'
  root to: 'home#index'
end
