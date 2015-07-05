Rails.application.routes.draw do
  get 'oauth2_callbacks/fitbit' => 'oauth2_callbacks#fitbit'
  resources :users
  root to: 'home#index'
end
