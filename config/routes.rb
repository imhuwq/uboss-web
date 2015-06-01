Rails.application.routes.draw do

  namespace :admin do
    root 'home#index'
  end

  root 'welcome#index'

  match '/admin', to: 'admin/main#index',via: :get
  namespace :admin do
    resources :users do
    end
    resources :sessions do
    end
  end
end
