Rails.application.routes.draw do

  devise_for :user, controllers: { 
    sessions: "users/sessions",
    passwords: "users/passwords",
  }

  resources :orders, only: [:new, :create, :show] do
    get 'pay', on: :member
    collection do
      post 'pingpp_callback'
      get 'success', to: 'orders#success_callback'
      get 'failure', to: 'orders#failure_callback'
    end
  end

  resource :charge, only: [:create] do
    post 'callback', on: :collection
  end

  authenticate :user, lambda { |user| user.admin? } do
    namespace :admin do
      resources :products, except: [:destroy] do
      end
      resources :orders, except: [:destroy] do
        patch :ship, on: :member
      end
      root 'dashboard#index'
    end
  end

  root 'home#index'
end
