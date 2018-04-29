Rails.application.routes.draw do
  get 'me', to: 'users#info'
  devise_for :users

  root 'welcome#index'

  # get 'artists/:id', to: 'artists#show', as: 'cualquiercosa'

  resources :artists, :albums, :songs

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
