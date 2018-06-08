Rails.application.routes.draw do
  get 'me', to: 'users#info'
  devise_for :users

  root 'welcome#index'

  resources :artists do
    resources :albums do
      resources :songs
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
